import 'player_model.dart';
import 'round_model.dart';

class RoomModel {
  const RoomModel({
    required this.id,
    required this.code,
    required this.status,
    required this.configuration,
    required this.players,
    required this.rounds,
    this.startedAt,
    this.finishedAt,
  });

  final int id;
  final String code;
  final String status;
  final RoomConfigurationModel configuration;
  final List<PlayerModel> players;
  final List<RoundModel> rounds;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final rawConfiguration = json['configuration'];
    final rawPlayers = json['players'];
    final rawRounds = json['rounds'];

    return RoomModel(
      id: _readInt(json['id']),
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      configuration: RoomConfigurationModel.fromJson(
        rawConfiguration is Map<String, dynamic>
            ? rawConfiguration
            : const <String, dynamic>{},
      ),
      players: rawPlayers is List
          ? rawPlayers
                .whereType<Map<String, dynamic>>()
                .map(PlayerModel.fromJson)
                .toList()
          : const [],
      rounds: rawRounds is List
          ? rawRounds
                .whereType<Map<String, dynamic>>()
                .map(RoundModel.fromJson)
                .toList()
          : const [],
      startedAt: _readDate(json['started_at']),
      finishedAt: _readDate(json['finished_at']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class RoomConfigurationModel {
  const RoomConfigurationModel({
    required this.categoryMode,
    required this.categories,
    required this.durationSeconds,
    required this.roundCount,
    required this.allowHardLetters,
  });

  final String categoryMode;
  final List<String> categories;
  final int durationSeconds;
  final int roundCount;
  final bool allowHardLetters;

  factory RoomConfigurationModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];

    return RoomConfigurationModel(
      categoryMode: json['category_mode']?.toString() ?? 'custom',
      categories: rawCategories is List
          ? rawCategories.map((value) => value.toString()).toList()
          : const [],
      durationSeconds: _readInt(json['duration_seconds']),
      roundCount: _readInt(json['round_count']),
      allowHardLetters: json['allow_hard_letters'] == true,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
