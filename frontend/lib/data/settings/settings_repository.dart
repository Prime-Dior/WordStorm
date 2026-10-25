/// Réglages locaux (phase 3, cahier §13) : pseudo, sons, vibrations,
/// animations réduites — persistés en `shared_preferences`.
library;

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository({this._prefs});

  SharedPreferences? _prefs;

  static const String _kNickname = 'settings.nickname';
  static const String _kSoundOn = 'settings.soundOn';
  static const String _kVibrationOn = 'settings.vibrationOn';
  static const String _kReduceAnimations = 'settings.reduceAnimations';

  // Valeurs par défaut (toutes fonctionnalités « plaisir » actives,
  // conformément au cahier §13 : réduction automatique des animations OS
  // côté UI à la phase 6).
  static const bool kDefaultSound = true;
  static const bool kDefaultVibration = true;
  static const bool kDefaultReduceAnimations = false;

  Future<SharedPreferences> _resolve() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Pseudo persisté (cahier : mémoriser le dernier pseudo, modifiable).
  Future<String> nickname() async =>
      (await _resolve()).getString(_kNickname) ?? '';

  Future<void> setNickname(String value) async {
    final p = await _resolve();
    await p.setString(_kNickname, value.trim());
  }

  Future<bool> soundOn() async =>
      (await _resolve()).getBool(_kSoundOn) ?? kDefaultSound;

  Future<void> setSoundOn(bool value) async =>
      (await _resolve()).setBool(_kSoundOn, value);

  Future<bool> vibrationOn() async =>
      (await _resolve()).getBool(_kVibrationOn) ?? kDefaultVibration;

  Future<void> setVibrationOn(bool value) async =>
      (await _resolve()).setBool(_kVibrationOn, value);

  Future<bool> reduceAnimations() async =>
      (await _resolve()).getBool(_kReduceAnimations) ??
      kDefaultReduceAnimations;

  Future<void> setReduceAnimations(bool value) async =>
      (await _resolve()).setBool(_kReduceAnimations, value);
}
