import '../../domain/models/lobby_setup.dart';

/// État partagé du salon actif, utilisé entre l'attente et les manches.
class MultiplayerSession {
  const MultiplayerSession({
    required this.code,
    required this.setup,
    required this.isHost,
  });

  final String code;
  final LobbySetup setup;
  final bool isHost;
}

// L'API conserve les mêmes libellés français que l'interface.
String categoryFromApi(String value) => value;
String categoryToApi(String value) => value;

class ApiRoomState {
  const ApiRoomState({
    required this.code,
    required this.status,
    required this.players,
    required this.rounds,
    required this.setup,
    required this.isHost,
  });

  final String code;
  final String status;
  final List<dynamic> players;
  final List<dynamic> rounds;
  final LobbySetup setup;
  final bool isHost;

  Map<String, dynamic> toMap() => {
    'code': code,
    'status': status,
    'players': players,
    'rounds': rounds,
    'setup': setup,
    'isHost': isHost,
  };
}

ApiRoomState mapApiRoom(Map<String, dynamic> room, {required bool isHost}) {
  final configuration = (room['configuration'] as Map).cast<String, dynamic>();
  return ApiRoomState(
    code: room['code'] as String,
    status: room['status'] as String,
    players: (room['players'] as List?) ?? const [],
    rounds: (room['rounds'] as List?) ?? const [],
    setup: LobbySetup(
      categories: (configuration['categories'] as List)
          .map((value) => categoryFromApi('$value'))
          .toList(growable: false),
      durationSeconds: configuration['duration_seconds'] as int,
      rounds: configuration['round_count'] as int,
      allowHardLetters: configuration['allow_hard_letters'] as bool,
      randomCategories: configuration['category_mode'] == 'random',
    ),
    isHost: isHost,
  );
}
