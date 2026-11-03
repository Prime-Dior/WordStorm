import 'package:flutter_test/flutter_test.dart';
import 'package:wordstorm/data/api/api_client.dart';
import 'package:wordstorm/data/repository/room_repository.dart';

void main() {
  late _RecordingApiClient api;
  late RoomRepository rooms;

  setUp(() {
    api = _RecordingApiClient();
    rooms = RoomRepository(api);
  });

  test(
    'random room creation omits categories and parses the server room',
    () async {
      api.response = _roomResponse();

      final room = await rooms.createRoom(
        categoryMode: 'random',
        durationSeconds: 60,
        roundCount: 3,
        allowHardLetters: false,
      );

      expect(api.lastPath, '/rooms');
      expect(api.lastBody?['category_mode'], 'random');
      expect(api.lastBody!.containsKey('categories'), isFalse);
      expect(room.code, 'ABC234');
    },
  );

  test('joining normalizes code before posting it', () async {
    api.response = _roomResponse();

    final room = await rooms.joinRoom(' abc234 ');

    expect(api.lastPath, '/rooms/join');
    expect(api.lastBody, {'code': 'ABC234'});
    expect(room.players.single.nickname, 'Ada');
  });
}

class _RecordingApiClient extends ApiClient {
  String? lastPath;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic> response = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    lastPath = path;
    lastBody = body;
    return response;
  }
}

Map<String, dynamic> _roomResponse() => {
  'data': {
    'id': 4,
    'code': 'ABC234',
    'status': 'waiting',
    'configuration': {
      'category_mode': 'random',
      'categories': ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
      'duration_seconds': 60,
      'round_count': 3,
      'allow_hard_letters': false,
    },
    'players': [
      {'id': 1, 'nickname': 'Ada', 'is_host': true},
    ],
    'rounds': [],
  },
};
