import 'package:flutter_test/flutter_test.dart';
import 'package:wordstorm/domain/models/room_model.dart';
import 'package:wordstorm/domain/models/round_model.dart';

void main() {
  test('RoomModel parses room configuration, players, and waiting rounds', () {
    final room = RoomModel.fromJson({
      'id': 12,
      'code': 'ABC234',
      'status': 'in_progress',
      'configuration': {
        'category_mode': 'custom',
        'categories': ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
        'duration_seconds': 60,
        'round_count': 2,
        'allow_hard_letters': true,
      },
      'players': [
        {
          'id': 5,
          'nickname': 'Ada',
          'is_host': true,
          'joined_at': '2026-11-03T10:00:00Z',
        },
      ],
      'rounds': [
        {
          'number': 1,
          'letter': 'A',
          'status': 'active',
          'starts_at': '2026-11-03T10:01:00Z',
          'ends_at': '2026-11-03T10:02:00Z',
        },
      ],
    });

    expect(room.code, 'ABC234');
    expect(room.configuration.categories, contains('Prénom'));
    expect(room.players.single.isHost, isTrue);
    expect(room.rounds.single.status, 'active');
    expect(room.rounds.single.letter, 'A');
  });

  test('RoundModel parses scored answers and keeps nullable fields', () {
    final round = RoundModel.fromJson({
      'number': 1,
      'status': 'completed',
      'answers': [
        {
          'player_id': 9,
          'nickname': 'Ada',
          'category': 'Prénom',
          'value': 'Alice',
          'validation_status': 'valid',
          'points': 15,
          'score_reason': 'unique',
        },
      ],
    });

    expect(round.answers.single.nickname, 'Ada');
    expect(round.answers.single.points, 15);
    expect(round.endsAt, isNull);
  });
}
