import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/domain/categories.dart';
import 'package:wordstorm/domain/rules_config.dart';
import 'package:wordstorm/domain/scoring.dart';
import 'package:wordstorm/domain/validation.dart';

PlayerRoundAnswers _p(String id, Map<String, String> answers) =>
    PlayerRoundAnswers(playerId: id, answers: answers);

const _config = RulesConfig();

RoundScore _score({
  required List<String> categories,
  required List<PlayerRoundAnswers> players,
  String letter = 'R',
  UsedWords? used,
  DictionaryLookup? dictionary,
  RulesConfig? config,
  bool solo = false,
}) => RoundScoring.scoreRound(
  config: (config ?? _config).withSolo(solo),
  letter: letter,
  categories: categories,
  players: players,
  dictionary: dictionary,
  used: used,
);

extension on RulesConfig {
  RulesConfig withSolo(bool solo) => RulesConfig(
    onlyValidPoints: onlyValidPoints,
    uniqueValidPoints: uniqueValidPoints,
    sharedPoints: sharedPoints,
    invalidPoints: invalidPoints,
    reusedPoints: reusedPoints,
    conflictPolicy: conflictPolicy,
    allowHardLetters: allowHardLetters,
    minWordLength: minWordLength,
    minProperNounLength: minProperNounLength,
    soloMode: solo,
  );
}

void main() {
  group('paliers multijoueur', () {
    test('catégorie 1 : deux joueurs identiques → 5 et 5', () {
      final score = _score(
        categories: ['Prénom'],
        players: [
          _p('anna', {'Prénom': 'Rose'}),
          _p('ben', {'Prénom': 'Rose'}),
        ],
      );
      expect(score.lineFor('anna', 'Prénom').points, 5);
      expect(score.lineFor('ben', 'Prénom').points, 5);
      expect(score.lineFor('anna', 'Prénom').tier, ScoreTier.shared);
    });

    test('catégorie 2 : une seule réponse valide → 15 (bonus)', () {
      final score = _score(
        categories: ['Ville'],
        players: [
          _p('anna', {'Ville': 'Rennes'}),
          _p('ben', {'Ville': ''}),
          _p('cyril', {'Ville': 'Lyon'}),
        ],
      );
      expect(score.lineFor('anna', 'Ville').points, 15);
      expect(score.lineFor('anna', 'Ville').tier, ScoreTier.onlyValid);
      expect(score.lineFor('ben', 'Ville').points, 0);
      expect(score.lineFor('ben', 'Ville').reason, 'Pas de réponse');
      expect(score.lineFor('cyril', 'Ville').reason, 'Ne commence pas par R');
    });

    test('catégorie 3 : deux réponses valides différentes → 10 chacune', () {
      final score = _score(
        categories: ['Animal'],
        players: [
          _p('anna', {'Animal': 'Rat'}),
          _p('ben', {'Animal': 'Renard'}),
        ],
      );
      expect(score.lineFor('anna', 'Animal').points, 10);
      expect(score.lineFor('ben', 'Animal').points, 10);
      expect(score.lineFor('anna', 'Animal').tier, ScoreTier.uniqueValid);
    });

    test('identiques insensibles à la casse et aux accents', () {
      final score = _score(
        categories: ['Pays'],
        players: [
          _p('anna', {'Pays': 'Brésil'}),
          _p('ben', {'Pays': 'BRESIL'}),
        ],
        letter: 'B',
      );
      expect(score.lineFor('anna', 'Pays').points, 5);
      expect(score.lineFor('ben', 'Pays').points, 5);
    });

    test('invalide au dictionnaire → 0', () {
      final score = _score(
        categories: ['Animal'],
        players: [
          _p('a', {'Animal': 'Roro'}),
        ],
        dictionary: (category, word) => word == 'rat',
      );
      expect(score.lineFor('a', 'Animal').points, 0);
      expect(
        score.lineFor('a', 'Animal').reason,
        'Absent du dictionnaire (catégorie : Animal)',
      );
    });

    test('trop court → 0', () {
      final score = _score(
        categories: ['Animal'],
        players: [
          _p('a', {'Animal': 'R'}), // 1 seule lettre → trop court
        ],
      );
      expect(score.lineFor('a', 'Animal').points, 0);
      expect(score.lineFor('a', 'Animal').reason, 'Réponse trop courte');
    });
  });

  group('solo', () {
    test('toute réponse valide vaut 15 (prompt §4 : bonus aussi en solo)', () {
      final score = _score(
        categories: ['Objet'],
        players: [
          _p('solo', {'Objet': 'Radio'}),
        ],
        solo: true,
      );
      expect(score.lineFor('solo', 'Objet').points, 15);
      expect(score.lineFor('solo', 'Objet').tier, ScoreTier.onlyValid);
    });

    test('réponse invalide en solo → 0', () {
      final score = _score(
        categories: ['Objet'],
        players: [
          _p('solo', {'Objet': 'Vase'}),
        ],
        solo: true,
      );
      expect(score.lineFor('solo', 'Objet').points, 0);
    });
  });

  group('mot réutilisé (question ouverte Q1)', () {
    final cats = ['Animal'];

    test(
      'reuseWins : réutilisé mais seule réponse valide → 5 + badge conflit',
      () {
        final used = UsedWords()..add('Animal', 'rat');
        final score = _score(
          categories: cats,
          players: [
            _p('a', {'Animal': 'Rat'}),
          ],
          used: used,
        );
        final line = score.lineFor('a', 'Animal');
        expect(line.points, 5);
        expect(line.conflict, isTrue, reason: 'badge « Règle à trancher »');
        expect(line.reused, isTrue);
        expect(line.reason, contains('règle à trancher'));
      },
    );

    test('bonusWins : réutilisé, Unique → bonus 15 + badge', () {
      final used = UsedWords()..add('Animal', 'rat');
      final score = _score(
        categories: cats,
        players: [
          _p('a', {'Animal': 'Rat'}),
        ],
        used: used,
        config: const RulesConfig(conflictPolicy: ConflictPolicy.bonusWins),
      );
      final line = score.lineFor('a', 'Animal');
      expect(line.points, 15);
      expect(line.conflict, isTrue);
      expect(line.reused, isTrue);
    });

    test('réutilisé et identique à une autre réponse → 5, sans conflit', () {
      final used = UsedWords()..add('Animal', 'rat');
      final score = _score(
        categories: cats,
        players: [
          _p('a', {'Animal': 'Rat'}),
          _p('b', {'Animal': 'Rat'}),
        ],
        used: used,
      );
      for (final p in ['a', 'b']) {
        final line = score.lineFor(p, 'Animal');
        expect(line.points, 5);
        expect(line.conflict, isFalse);
      }
    });

    test('réutilisé dans une autre catégorie : pas de pénalité', () {
      // « Rat » a servi en Animal ; en Objet le même mot reste autorisé
      // (cahier §16.1) et se note normalement.
      final used = UsedWords()..add('Animal', 'rat');
      final score = _score(
        categories: ['Objet'],
        players: [
          _p('a', {'Objet': 'Rat de labour'}),
        ],
        used: used,
      );
      final line = score.lineFor('a', 'Objet');
      expect(line.points, 15);
      expect(line.reused, isFalse);
    });

    test('manche suivante : le mot consommé est bien bloqué', () {
      // Manche 1.
      final used = UsedWords();
      final first = _score(
        categories: ['Animal'],
        players: [
          _p('a', {'Animal': 'Renard'}),
        ],
        used: used,
      );
      registerRoundWords(used, {
        'Animal': [],
      }); // enregistrement explicite ci-dessous
      // Enregistre la réponse valide de la manche 1 :
      used.add('Animal', 'renard');
      expect(first.totalFor('a'), 15);

      // Manche 2 : « Renard » à nouveau en Animal.
      final second = _score(
        categories: ['Animal'],
        players: [
          _p('a', {'Animal': 'Renard'}),
        ],
        used: used,
      );
      final line = second.lineFor('a', 'Animal');
      expect(line.reused, isTrue);
      expect(line.points, 5); // reuseWins (provisoire)
      expect(line.conflict, isTrue);
    });
  });

  group('totaux', () {
    test('totalFor additionne les catégories', () {
      final score = _score(
        categories: ['Prénom', 'Ville'],
        players: [
          _p('a', {'Prénom': 'Rose', 'Ville': 'Rennes'}),
          _p('b', {'Prénom': 'Rose', 'Ville': 'Reims'}),
        ],
      );
      // Ville : deux réponses valides différentes → 10 chacune (pas de bonus).
      expect(score.totalFor('a'), 5 + 10);
      expect(score.totalFor('b'), 5 + 10);
      expect(score.lineFor('a', 'Ville').tier, ScoreTier.uniqueValid);
    });

    test('une seule réponse valide dans la catégorie → bonus 15', () {
      final score = _score(
        categories: ['Ville'],
        players: [
          _p('a', {'Ville': 'Rennes'}),
          _p('b', {'Ville': 'Lyon'}), // mauvaise lettre → 0
        ],
      );
      expect(score.totalFor('a'), 15);
      expect(score.lineFor('a', 'Ville').tier, ScoreTier.onlyValid);
    });

    test('réponse absente de la map = ligne « Pas de réponse » à 0', () {
      final score = _score(categories: ['Objet'], players: [_p('a', {})]);
      expect(score.lineFor('a', 'Objet').points, 0);
      expect(score.totalFor('a'), 0);
    });
  });

  group('toutes les catégories du jeu sont traitées', () {
    test('aucune exception sur le spectre complet', () {
      final all = [...Categories.mandatory, ...Categories.optional];
      final score = _score(
        categories: all,
        players: [
          _p('a', {for (final c in all) c: 'Raza'}),
        ],
      );
      expect(score.totalFor('a'), greaterThan(0));
    });
  });
}
