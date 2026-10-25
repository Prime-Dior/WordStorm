/// Dépôt d'historique local (phase 6 — cahier §5.1 « Sauvegarde locale
/// minimale de la configuration et de l'historique », §5.2 statistiques).
///
/// Persistance `shared_preferences` en JSON ; aucune dépendance
/// réseau. Le classement global reste hors périmètre (décision prompt
/// : pas de serveur pour l'historique — écran du menu fidèle).
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Une partie jouée, enregistrée à sa fin (solo en phase 6 ; le multi
/// enregistrera ses parties en phase 7 avec le même dépôt).
@immutable
class GameRecord {
  const GameRecord({
    required this.id,
    required this.dateIso,
    required this.mode,
    required this.rounds,
    required this.totalScore,
    required this.categories,
    required this.letters,
  });

  /// Identifiant UTC (millisecondes + compteur local) pour le tri.
  final String id;

  /// ISO 8601 `yyyy-MM-ddTHH:mm`.
  final String dateIso;
  final String mode; // 'solo' ; 'multi' à la phase 7.
  final int rounds;
  final int totalScore;

  /// Catégories jouées (affichage synthétique).
  final List<String> categories;

  /// Lettres tirées dans l'ordre des manches.
  final List<String> letters;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'dateIso': dateIso,
    'mode': mode,
    'rounds': rounds,
    'totalScore': totalScore,
    'categories': categories,
    'letters': letters,
  };

  factory GameRecord.fromJson(Map<String, Object?> json) => GameRecord(
    id: json['id']! as String,
    dateIso: json['dateIso']! as String,
    mode: json['mode']! as String,
    rounds: json['rounds']! as int,
    totalScore: json['totalScore']! as int,
    categories: [...(json['categories']! as List).cast<String>()],
    letters: [...(json['letters']! as List).cast<String>()],
  );

  /// Date courte lisible en français : « 24/10 2026 ».
  String get dateLabel {
    final parts = dateIso.split('T').first.split('-');
    if (parts.length != 3) return dateIso;
    return '${parts[2]}/${parts[1]} ${parts[0]}';
  }
}

/// Statistiques agrégées de l'historique (écran record).
@immutable
class HistoryStats {
  const HistoryStats({
    required this.games,
    required this.bestScore,
    required this.averageScore,
    required this.lastScore,
  });

  final int games;
  final int bestScore;
  final int averageScore; // arrondi supérieur
  final int lastScore;
}

abstract interface class HistoryRepository {
  /// Persiste une partie terminée (dédupliqué par identifiant).
  Future<void> save(GameRecord record);

  /// Historique complet, du plus récent au plus ancien.
  Future<List<GameRecord>> all();

  /// Efface l'historique (action utilisateur, bouton de l'écran).
  Future<void> clear();
}

/// Implémentation locale (clé unique JSON dans shared_preferences).
class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository();

  static const String _key = 'wordstorm.history.v1';

  List<GameRecord>? _cache;

  @override
  Future<void> save(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    // Copie modifiable : le cache peut être une liste constante (vide
    // après clear()) — la déduplication et le tri mutent la liste.
    final records = [...await _read(prefs)];
    records.removeWhere((r) => r.id == record.id);
    // Le plus récent en tête ; on plafonne à 100 parties.
    records
      ..insert(0, record)
      ..sort((a, b) => b.dateIso.compareTo(a.dateIso));
    while (records.length > 100) {
      records.removeLast();
    }
    _cache = records;
    await prefs.setString(
      _key,
      jsonEncode([for (final r in records) r.toJson()]),
    );
  }

  @override
  Future<List<GameRecord>> all() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  @override
  Future<void> clear() async {
    _cache = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<GameRecord>> _read(SharedPreferences prefs) async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return _cache = const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return _cache = [
      for (final e in decoded) GameRecord.fromJson(e as Map<String, dynamic>),
    ];
  }

  /// Statistiques dérivées, calculées sur la liste complète.
  static HistoryStats statsOf(List<GameRecord> records) {
    if (records.isEmpty) {
      return const HistoryStats(
        games: 0,
        bestScore: 0,
        averageScore: 0,
        lastScore: 0,
      );
    }
    final last = records.first.totalScore;
    final best = records.fold(0, (m, r) => m < r.totalScore ? r.totalScore : m);
    final sum = records.fold(0, (s, r) => s + r.totalScore);
    return HistoryStats(
      games: records.length,
      bestScore: best,
      averageScore: (sum / records.length).ceil(),
      lastScore: last,
    );
  }
}
