/// Implémentation locale du dictionnaire, embarquée dans l'app
/// (`assets/words/words.json`, 2 226 mots / 18 listes exportés du
/// prototype Petit Bac — voir `docs/ANALYSE.md` §4).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:wordstorm/domain/normalization.dart';

import 'dictionary_repository.dart';

const String kWordsAssetPath = 'assets/words/words.json';

class AssetDictionaryRepository implements DictionaryRepository {
  final Map<String, Set<String>> _sets = {};
  bool _loaded = false;

  @override
  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(kWordsAssetPath);

    // Décodage hors main isolate (prompt §11 phase 3) : le JSON fait
    // environ 40 Ko / 2 226 mots, `compute` évite tout jank au démarrage.
    final Map<String, Set<String>> decoded = await compute(_parseWords, raw);

    _sets
      ..clear()
      ..addAll(decoded);
    _loaded = true;
  }

  @override
  Set<String>? wordSet(String category) {
    assert(_loaded, 'appeler load() avant wordSet()');
    final key = kCategoryToDictionary[category];
    if (key == null) return null;
    return _sets[key];
  }

  @override
  Iterable<String> get availableCategories => _sets.keys;

  /// Accès brut aux listes indexées par leur clé d'origine du JSON
  /// (« Fruit ou légume », « Marque »…). Usage dépôt/tests.
  Map<String, Set<String>> get rawSets => Map.unmodifiable(_sets);

  /// Parse JSON → ensembles normalisés (fonction de niveau haut pour
  /// pouvoir tourner sous `compute`).
  static Map<String, Set<String>> _parseWords(String raw) {
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in json.entries)
        entry.key: {
          for (final w in (entry.value as List<dynamic>))
            normalizeAnswer(w as String),
        },
    };
  }
}
