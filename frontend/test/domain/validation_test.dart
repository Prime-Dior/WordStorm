import 'package:flutter_test/flutter_test.dart';
import 'package:wordstorm/domain/normalization.dart';
import 'package:wordstorm/domain/rules_config.dart';
import 'package:wordstorm/domain/validation.dart';

void main() {
  group('normalizeAnswer', () {
    test('minuscules, trim', () {
      expect(normalizeAnswer('  Radio '), 'radio');
      expect(normalizeAnswer('PARIS'), 'paris');
    });

    test('insensible aux accents', () {
      expect(normalizeAnswer('Éléphant'), 'elephant');
      expect(normalizeAnswer('Cœurs'), 'coeurs');
      expect(normalizeAnswer('Nîmes'), 'nimes');
      expect(normalizeAnswer('Château-fort'), 'chateau-fort');
      expect(normalizeAnswer("L'Apostrophe"), 'l\'apostrophe');
    });

    test('chaîne vide conservée vide', () {
      expect(normalizeAnswer(''), '');
      expect(normalizeAnswer('   '), '');
    });
  });

  group('sanitizeInput', () {
    test('ne laisse que lettres, accents, espaces, tirets, apostrophes', () {
      expect(sanitizeInput('Pré-nom 12!'), 'Pré-nom ');
      expect(sanitizeInput("L'Été,;"), "L'Été");
      expect(sanitizeInput('chien@chat'), 'chienchat');
      expect(sanitizeInput('42'), '');
    });
  });

  group('startsWithLetter', () {
    test('casse et accents ignorés', () {
      expect(startsWithLetter('École', 'E'), isTrue);
      expect(startsWithLetter('érable', 'E'), isTrue);
      expect(startsWithLetter('école', 'R'), isFalse);
      expect(startsWithLetter('', 'R'), isFalse);
    });
  });

  group('checkAnswer', () {
    const config = RulesConfig();

    test('vide → problème empty', () {
      final c = checkAnswer(
        category: 'Ville',
        answer: '',
        letter: 'R',
        config: config,
      );
      expect(c.isValid, isFalse);
      expect(c.verdict.problem, AnswerProblem.empty);
    });

    test('mauvaise lettre', () {
      final c = checkAnswer(
        category: 'Ville',
        answer: 'Lyon',
        letter: 'R',
        config: config,
      );
      expect(c.verdict.problem, AnswerProblem.wrongLetter);
    });

    test('accent sur la première lettre accepté', () {
      final c = checkAnswer(
        category: 'Ville',
        answer: 'Évreux',
        letter: 'E',
        config: config,
      );
      expect(c.isValid, isTrue);
    });

    test('trop court : 1 lettre refusée partout', () {
      final c = checkAnswer(
        category: 'Objet',
        answer: 'A',
        letter: 'A',
        config: config,
      );
      expect(c.verdict.problem, AnswerProblem.tooShort);
    });

    test('2 lettres : ok hors Prénom', () {
      final c = checkAnswer(
        category: 'Pays',
        answer: 'Chine',
        letter: 'C',
        config: config,
      );
      expect(c.isValid, isTrue);
    });

    test('Prénom : règle souple 3 lettres minimum', () {
      final ok = checkAnswer(
        category: 'Prénom',
        answer: 'Ana',
        letter: 'A',
        config: config,
      );
      expect(ok.isValid, isTrue);

      final ko = checkAnswer(
        category: 'Prénom',
        answer: 'Al',
        letter: 'A',
        config: config,
      );
      expect(ko.verdict.problem, AnswerProblem.tooShort);
    });

    test('Prénom : le dictionnaire nest pas consulté', () {
      final c = checkAnswer(
        category: 'Prénom',
        answer: 'Zzzana',
        letter: 'Z',
        config: config,
        dictionary: (category, word) => false, // refuserait tout autrement
      );
      expect(c.isValid, isTrue);
    });

    test('dictionnaire consulté pour les catégories avec liste', () {
      bool? strictAll(String category, String word) => word == 'rat';
      final ok = checkAnswer(
        category: 'Animal',
        answer: 'Rat',
        letter: 'R',
        config: config,
        dictionary: strictAll,
      );
      expect(ok.isValid, isTrue);

      final ko = checkAnswer(
        category: 'Animal',
        answer: 'Roro',
        letter: 'R',
        config: config,
        dictionary: strictAll,
      );
      expect(ko.verdict.problem, AnswerProblem.notInDictionary);
    });

    test(
      'cas null du dictionnaire = validation souple (catégorie sans liste)',
      () {
        final c = checkAnswer(
          category: 'Fleuve',
          answer: 'Rhin',
          letter: 'R',
          config: config,
          dictionary: (category, word) => null,
        );
        expect(c.isValid, isTrue);
      },
    );

    test('mot réutilisé même catégorie détecté, pas dans une autre', () {
      final used = UsedWords()..add('Ville', 'rennes');
      final c = checkAnswer(
        category: 'Ville',
        answer: 'Rennes',
        letter: 'R',
        config: config,
        used: used,
      );
      expect(c.reused, isTrue);

      final other = checkAnswer(
        category: 'Pays', // autre catégorie : le même mot reste autorisé
        answer: 'Rennes',
        letter: 'R',
        config: config,
        used: used,
      );
      expect(other.reused, isFalse);
      expect(other.isValid, isTrue);
    });

    test('la casse/accents exacts du mot réutilisé importent peu', () {
      final used = UsedWords()..add('Animal', 'elephant');
      final c = checkAnswer(
        category: 'Animal',
        answer: 'Éléphant',
        letter: 'E',
        config: config,
        used: used,
      );
      expect(c.reused, isTrue);
    });
  });

  group('registerRoundWords', () {
    test('n\'enregistre que les réponses valides', () {
      final used = UsedWords();
      registerRoundWords(used, {
        'Ville': [
          const AnswerCheck(verdict: Verdict.valid(), normalized: 'rennes'),
          const AnswerCheck(
            verdict: Verdict.invalid(AnswerProblem.wrongLetter),
            normalized: 'lyon',
          ),
        ],
      });
      expect(used.wasUsed('Ville', 'rennes'), isTrue);
      expect(used.wasUsed('Ville', 'lyon'), isFalse);
    });
  });
}
