import 'room_model.dart';
import 'round_model.dart';

class MultiplayerRoundSession {
  const MultiplayerRoundSession({
    required this.roomCode,
    required this.nickname,
    required this.isHost,
    required this.round,
    required this.categories,
    required this.durationSeconds,
    required this.roundCount,
  });

  final String roomCode;
  final String nickname;
  final bool isHost;
  final RoundModel round;
  final List<String> categories;
  final int durationSeconds;
  final int roundCount;

  factory MultiplayerRoundSession.fromRoom({
    required RoomModel room,
    required RoundModel round,
    required String nickname,
    required bool isHost,
  }) => MultiplayerRoundSession(
    roomCode: room.code,
    nickname: nickname,
    isHost: isHost,
    round: round,
    categories: room.configuration.categories,
    durationSeconds: room.configuration.durationSeconds,
    roundCount: room.configuration.roundCount,
  );
}
