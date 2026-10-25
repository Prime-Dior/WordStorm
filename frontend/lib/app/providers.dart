/// Providers applicatifs (riverpod) — injection des dépôts et de la
/// session de jeu. Les implémentations restent interchangeables (le
/// multi de la phase 7 introduira un provider de salon).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sound_engine.dart';
import '../data/dictionary/asset_dictionary_repository.dart';
import '../data/history/history_repository.dart';
import '../data/settings/settings_repository.dart';
import '../features/game/state/solo_session.dart';

/// Dictionnaire embarqué (chargement différé, idempotent).
final dictionaryProvider = Provider<AssetDictionaryRepository>(
  (ref) => AssetDictionaryRepository(),
);

/// Historique local des parties (shared_preferences). Le multi de la
/// phase 7 enregistre dans le même dépôt.
final historyProvider = Provider<HistoryRepository>(
  (ref) => LocalHistoryRepository(),
);

/// Réglages locaux (shared_preferences).
final settingsProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

/// Sons générés (phase 6) : pilotés par le réglage local `soundOn`.
final soundEngineProvider = Provider<SoundEngine>((ref) {
  final settings = ref.read(settingsProvider);
  return SoundEngine(soundOn: settings.soundOn);
});

/// Vibrations (phase 6) : gouvernées par le réglage local `vibrationOn`.
final vibrationProvider = Provider<VibrationEngine>((ref) {
  final settings = ref.read(settingsProvider);
  return VibrationEngine(vibrationOn: settings.vibrationOn);
});

/// Session de jeu en cours (solo ; le multi ajoutera un salon séparé).
final soloSessionProvider =
    StateNotifierProvider<SoloSessionController, SoloSessionState>(
      SoloSessionController.new,
    );
