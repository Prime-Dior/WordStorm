import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/domain/rules_config.dart';
import 'package:wordstorm/domain/scoring.dart';

/// Exemple de référence du cahier §16.1 : la manche de référence doit
/// produire **Anna 35, Ben 15, Cyril 15**.
///
/// Le cahier donne uniquement les trois totaux ; le scénario ci-dessous est
/// **inféré** (documenté dans `docs/ANALYSE.md` §6) pour couvrir tous les
/// paliers du barème :
///
/// | Catégorie | Anna | Ben | Cyril | Sens               |
/// |-----------|------|-----|-------|--------------------|
/// | Prénom    | Rose | Rose| Rania | 5 / 5 / 10         |
/// | Ville     | Rennes | Lyon | (vide) | 15 / 0 / 0     |
/// | Animal    | Rat  | Chat| Rat   | 5 / 0 / 5          |
/// | Objet     | Radio| Robot| (vide) | 10 / 10 / 0     |
///
/// Lettre tirée : R. Aucun dictionnaire (toutes les réponses passent la
/// validation lettre + longueur).
void main() {
  test('La manche de référence produit Anna 35, Ben 15, Cyril 15', () {
    const categories = ['Prénom', 'Ville', 'Animal', 'Objet'];
    const letter = 'R';

    final round = RoundScoring.scoreRound(
      config: const RulesConfig(),
      letter: letter,
      categories: categories,
      players: [
        const PlayerRoundAnswers(
          playerId: 'anna',
          answers: {
            'Prénom': 'Rose',
            'Ville': 'Rennes',
            'Animal': 'Rat',
            'Objet': 'Radio',
          },
        ),
        const PlayerRoundAnswers(
          playerId: 'ben',
          answers: {
            'Prénom': 'Rose',
            'Ville': 'Lyon', // ne commence pas par R → 0
            'Animal': 'Chat', // ne commence pas par R → 0
            'Objet': 'Robot',
          },
        ),
        const PlayerRoundAnswers(
          playerId: 'cyril',
          answers: {
            'Prénom': 'Rania',
            'Ville': '', // pas de réponse → 0
            'Animal': 'Rat',
            'Objet': '', // pas de réponse → 0
          },
        ),
      ],
    );

    expect(round.totalFor('anna'), 35, reason: 'cahier §16.1 : Anna = 35');
    expect(round.totalFor('ben'), 15, reason: 'cahier §16.1 : Ben = 15');
    expect(round.totalFor('cyril'), 15, reason: 'cahier §16.1 : Cyril = 15');

    // Contrôles de détail des règles appliquées.
    expect(round.lineFor('anna', 'Prénom').points, 5); // identique à Ben
    expect(round.lineFor('ben', 'Prénom').points, 5);
    expect(round.lineFor('cyril', 'Prénom').points, 10); // unique
    expect(round.lineFor('anna', 'Ville').points, 15); // seule → bonus
    expect(round.lineFor('ben', 'Ville').reason, 'Ne commence pas par R');
    expect(round.lineFor('cyril', 'Ville').reason, 'Pas de réponse');
    expect(round.lineFor('anna', 'Animal').points, 5); // identique à Cyril
    expect(round.lineFor('cyril', 'Animal').points, 5);
    expect(round.lineFor('ben', 'Animal').points, 0);
    expect(round.lineFor('anna', 'Objet').points, 10); // unique
    expect(round.lineFor('ben', 'Objet').points, 10); // unique
  });
}
