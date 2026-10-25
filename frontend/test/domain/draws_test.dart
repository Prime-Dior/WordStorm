import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/domain/categories.dart';
import 'package:wordstorm/domain/draws.dart';
import 'package:wordstorm/domain/rules_config.dart';

void main() {
  group('tirage de lettre', () {
    test('K W X Y Z exclues par défaut (Q inclus)', () {
      final drawn = <String>{};
      for (var i = 0; i < 300; i++) {
        drawn.add(Draws.drawLetter(config: const RulesConfig()));
      }
      for (final hard in RulesConfig.hardLetters) {
        expect(
          drawn.contains(hard),
          isFalse,
          reason: '$hard doit être exclue du pool par défaut',
        );
      }
      expect(
        drawn.contains('Q'),
        isTrue,
        reason: 'Q est incluse (prompt §6, divergence maquette)',
      );
      expect(drawn, containsAll(['A', 'R', 'T']));
    });

    test('lettres difficiles incluses si option activée', () {
      const config = RulesConfig(allowHardLetters: true);
      final drawn = <String>{};
      for (var i = 0; i < 500; i++) {
        drawn.add(Draws.drawLetter(config: config));
      }
      for (final hard in RulesConfig.hardLetters) {
        expect(drawn.contains(hard), isTrue, reason: '$hard doit sortir');
      }
    });

    test('pas de répétition tant que le pool a des lettres libres', () {
      const config = RulesConfig();
      // Pool fixe volontairement réduit à la main : les lettres R, A, T
      // (consommées) ne peuvent plus sortir.
      const used = {'R', 'A', 'T'};
      for (var i = 0; i < 100; i++) {
        final letter = Draws.drawLetter(config: config, usedLetters: used);
        expect(
          used.contains(letter),
          isFalse,
          reason: 'une lettre déjà tirée ne doit pas revenir',
        );
      }
    });

    test('pool épuisé : remise en jeu (jamais de crash)', () {
      final used = {'A'}
          .union(Draws.defaultPool.split('').toSet()); // tout le pool consommé
      final letter = Draws.drawLetter(
        config: const RulesConfig(),
        usedLetters: used,
      );
      expect(Draws.defaultPool.contains(letter), isTrue);
    });
  });

  group('catégories aléatoires', () {
    test('socle 5 obligatoires + 4 aléatoires, total 9', () {
      final cats = Draws.pickRandomCategories();
      expect(cats.length, Categories.mandatoryCount + 4);
      expect(cats.length, lessThanOrEqualTo(Categories.maxPerGame));
      for (final m in Categories.mandatory) {
        expect(cats.contains(m), isTrue, reason: '$m obligatoire');
      }
    });

    test('pas de doublon et uniquement des catégories connues', () {
      for (var i = 0; i < 50; i++) {
        final cats = Draws.pickRandomCategories();
        expect(cats.toSet().length, cats.length, reason: 'doublon !');
        for (final c in cats) {
          expect(
            Categories.mandatory.contains(c) || Categories.optional.contains(c),
            isTrue,
          );
        }
      }
    });

    test('la partie optionnelle varie dun tirage à lautre', () {
      final seen = <String>{};
      for (var i = 0; i < 30; i++) {
        final extras = Draws.pickRandomCategories().skip(
          Categories.mandatoryCount,
        );
        seen.addAll(extras);
      }
      // Avec 4 sur 15 optionnelles par tirage, 30 tirages doivent en
      // rencontrer strictement plus que 4 différentes.
      expect(seen.length, greaterThan(4));
    });
  });

  group('validité dune sélection', () {
    test('selection valide acceptée', () {
      expect(
        Categories.isValidSelection([...Categories.mandatory, 'Fleuve']),
        isTrue,
      );
    });

    test('sans les obligatoires → invalide', () {
      expect(Categories.isValidSelection(['Fleuve', 'Film']), isFalse);
    });

    test('plus de 12 catégories → invalide', () {
      final tooMany = [...Categories.mandatory, ...Categories.optional.take(8)];
      expect(tooMany.length, greaterThan(Categories.maxPerGame));
      expect(Categories.isValidSelection(tooMany), isFalse);
    });

    test('doublon → invalide', () {
      expect(
        Categories.isValidSelection([...Categories.mandatory, 'Film', 'Film']),
        isFalse,
      );
    });

    test('catégorie inconnue → invalide', () {
      expect(
        Categories.isValidSelection([...Categories.mandatory, 'Astrologie']),
        isFalse,
      );
    });
  });
}
