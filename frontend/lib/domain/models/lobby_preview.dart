import 'lobby_setup.dart';
import 'room_model.dart';

/// Données de l'aperçu local d'un salon, en attendant son raccordement API.
class LobbyPreview {
  const LobbyPreview({
    required this.code,
    required this.nickname,
    required this.isHost,
    this.setup,
  });

  final String code;
  final String nickname;
  final bool isHost;
  final LobbySetup? setup;

  factory LobbyPreview.fromRoom({
    required RoomModel room,
    required String nickname,
    required bool isHost,
  }) => LobbyPreview(
    code: room.code,
    nickname: nickname,
    isHost: isHost,
    setup: LobbySetup(
      categories: room.configuration.categories,
      durationSeconds: room.configuration.durationSeconds,
      rounds: room.configuration.roundCount,
      allowHardLetters: room.configuration.allowHardLetters,
      randomCategories: room.configuration.categoryMode == 'random',
    ),
  );
}
