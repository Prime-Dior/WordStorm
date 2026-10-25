import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/domain/rules_config.dart';
import 'package:wordstorm/domain/scoring.dart';
import 'package:wordstorm/domain/validation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetDictionaryRepository dictionary;
  setUpAll(() async {
    dictionary = AssetDictionaryRepository();
    await dictionary.load();
  });

  group('chargement du dictionnaire embarqué', () {
    test('18 listes, au moins 2 200 mots cumulés', () {
      final all = dictionary.availableCategories.toSet();
      expect(all.length, 18);
      expect(
        all,
        containsAll([
          'Prénom',
          'Animal',
          'Pays',
          'Ville',
          'Objet',
          'Métier',
          'Sport',
          'Fruit ou légume',
          'Couleur',
          'Marque',
          'Capitale',
          'Partie du corps',
        ]),
      );
      var total = 0;
      for (final c in dictionary.rawSets.values) {
        total += c.length;
      }
      expect(total, 2226);
    });

    test('les mots sont normalisés (accents/casse)', () {
      final animals = dictionary.wordSet('Animal')!;
      expect(animals.contains('rat'), isTrue); // « Rat » normalisé
      expect(animals.contains('Rat'), isFalse);
    });
  });

  group('mapping catégories Wordstorm → dictionnaire', () {
    test('catégories couvertes retourne un ensemble', () {
      for (final category in [
        'Prénom',
        'Ville',
        'Pays',
        'Animal',
        'Objet',
        'Métier',
        'Sport',
        'Partie du corps',
        'Fruit',
        'Légume',
        'Marque de voiture',
        'Groupe de musique',
      ]) {
        expect(dictionary.wordSet(category), isNotNull, reason: category);
      }
    });

    test('catégories sans liste → null (validation souple, Q2)', () {
      for (final category in [
        'Fleuve',
        'Plante',
        'Nourriture',
        'Film',
        'Personnage de conte',
        'Matière scolaire',
        'Maladie',
        'Chanson',
      ]) {
        expect(dictionary.wordSet(category), isNull, reason: category);
      }
    });
  });

  group('moteur branché au dictionnaire réel', () {
    test('« Rat » validé, « Zzzorge » refusé en Animal', () {
      const config = RulesConfig();
      final ok = checkAnswer(
        category: 'Animal',
        answer: 'Rat',
        letter: 'R',
        config: config,
        used: UsedWords(),
        dictionary: (category, word) =>
            dictionary.wordSet(category)?.contains(word),
      );
      expect(ok.isValid, isTrue);

      final ko = checkAnswer(
        category: 'Animal',
        answer: 'Zzzorge',
        letter: 'Z',
        config: config,
        used: UsedWords(),
        dictionary: (category, word) =>
            dictionary.wordSet(category)?.contains(word),
      );
      expect(ko.verdict.problem, AnswerProblem.notInDictionary);
    });

    test('catégorie sans liste passe en validation souple au réel', () {
      final line = RoundScoring.scoreRound(
        config: const RulesConfig(),
        letter: 'R',
        categories: ['Fleuve'],
        players: [
          const PlayerRoundAnswers(playerId: 'a', answers: {'Fleuve': 'Rhin'}),
        ],
        dictionary: (category, word) =>
            dictionary.wordSet(category)?.contains(word),
      ).lineFor('a', 'Fleuve');
      expect(line.tier, ScoreTier.onlyValid);
    });
  });
}
