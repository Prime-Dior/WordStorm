/// Providers applicatifs (riverpod) — injection des dépôts et de la
/// session de jeu. Les implémentations restent interchangeables (le
/// multi de la phase 7 introduira un provider de salon).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dictionary/asset_dictionary_repository.dart';
import '../data/settings/settings_repository.dart';
import '../features/game/state/solo_session.dart';

/// Dictionnaire embarqué (chargement différé, idempotent).
final dictionaryProvider = Provider<AssetDictionaryRepository>(
  (ref) => AssetDictionaryRepository(),
);

/// Réglages locaux (shared_preferences).
final settingsProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

/// Session de jeu en cours (solo ; le multi ajoutera un salon séparé).
final soloSessionProvider =
    StateNotifierProvider<SoloSessionController, SoloSessionState>(
      SoloSessionController.new,
    );
