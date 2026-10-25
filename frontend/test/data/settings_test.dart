import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordstorm/data/settings/settings_repository.dart';

void main() {
  setUp(() {
    // Backend mémoire (plugin mocké pour l'environnement de test).
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'défauts : pseudo vide, sons + vibrations ON, animations pleines',
    () async {
      final settings = SettingsRepository();
      expect(await settings.nickname(), '');
      expect(await settings.soundOn(), SettingsRepository.kDefaultSound);
      expect(
        await settings.vibrationOn(),
        SettingsRepository.kDefaultVibration,
      );
      expect(
        await settings.reduceAnimations(),
        SettingsRepository.kDefaultReduceAnimations,
      );
    },
  );

  test('écriture puis relecture (persistance simulée)', () async {
    final settings = SettingsRepository();
    await settings.setNickname('Lina');
    await settings.setSoundOn(false);
    await settings.setReduceAnimations(true);

    // Nouvelle instance : les valeurs persistent via SharedPreferences.
    final reloaded = SettingsRepository();
    expect(await reloaded.nickname(), 'Lina');
    expect(await reloaded.soundOn(), isFalse);
    expect(await reloaded.reduceAnimations(), isTrue);
    expect(await reloaded.vibrationOn(), isTrue); // jamais modifié
  });

  test('le pseudo est tronqué des espaces', () async {
    final settings = SettingsRepository();
    await settings.setNickname('  Max  ');
    expect(await settings.nickname(), 'Max');
  });
}
