import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/domain/rules_config.dart';

void main() {
  group('barème par défaut (cahier §7 + prompt §4)', () {
    const config = RulesConfig();

    test('points des paliers', () {
      expect(config.onlyValidPoints, 15);
      expect(config.uniqueValidPoints, 10);
      expect(config.sharedPoints, 5);
      expect(config.invalidPoints, 0);
      expect(config.reusedPoints, 5);
    });

    test('politique de conflit : reuseWins par défaut (provisoire)', () {
      expect(config.conflictPolicy, ConflictPolicy.reuseWins);
    });

    test('lettres difficiles exclues par défaut, Q toujours incluse', () {
      expect(config.allowHardLetters, isFalse);
      expect(RulesConfig.hardLetters, ['K', 'W', 'X', 'Y', 'Z']);
      expect(RulesConfig.hardLetters.contains('Q'), isFalse);
    });

    test('longueurs minimales', () {
      expect(config.minWordLength, 2);
      expect(config.minProperNounLength, 3);
    });

    test('durées de manche relevées de la maquette', () {
      expect(RulesConfig.turnDurations, [20, 30, 45, 60, 90, 120, 0]);
    });

    test('bornes de manches 1 à 5 (provisoire, prompt §4)', () {
      expect(RulesConfig.minRounds, 1);
      expect(RulesConfig.maxRounds, 5);
    });
  });

  group('politique bonusWins', () {
    test('constructible et distincte', () {
      const config = RulesConfig(conflictPolicy: ConflictPolicy.bonusWins);
      expect(config.conflictPolicy, ConflictPolicy.bonusWins);
    });
  });

  group('soloMode', () {
    test('en solo toute réponse valide vaut le palier du bonus', () {
      // Le comportement est vérifié fonctionnellement dans scoring_test
      // (cas solo : 15 points pour toute réponse valide) ; ici on fixe
      // seulement le contrat de configuration.
      const solo = RulesConfig(soloMode: true);
      expect(solo.soloMode, isTrue);
      expect(solo.onlyValidPoints, 15);
    });
  });
}
