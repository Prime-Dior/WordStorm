import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wordstorm/data/api/api_credentials.dart';
import 'package:wordstorm/data/api/wordstorm_api.dart';

void main() {
  test(
    'crée une session puis envoie le jeton Bearer à la création du salon',
    () async {
      final credentials = _MemoryCredentials();
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/guest')) {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'data': {
                  'access_token': 'jeton-test',
                  'player': {'id': 7, 'nickname': 'Lina'},
                },
              }),
            ),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': {
                'code': 'ABC234',
                'configuration': {
                  'category_mode': 'custom',
                  'categories': ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
                  'duration_seconds': 30,
                  'round_count': 2,
                  'allow_hard_letters': false,
                },
                'players': [],
                'rounds': [],
              },
            }),
          ),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final api = WordstormApi(
        client: client,
        credentials: credentials,
        baseUrl: 'http://localhost/api/v1',
      );

      await api.ensureGuestSession('Lina');
      final room = await api.createRoom(
        randomCategories: false,
        categories: ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
        durationSeconds: 30,
        rounds: 2,
        allowHardLetters: false,
      );

      expect(credentials.values['api_access_token'], 'jeton-test');
      expect(requests, hasLength(2));
      expect(requests.last.headers['Authorization'], 'Bearer jeton-test');
      expect(jsonDecode(requests.last.body)['categories'], contains('Prénom'));
      expect(room['code'], 'ABC234');
      client.close();
    },
  );

  test('réutilise une session invitée déjà conservée', () async {
    final credentials = _MemoryCredentials()
      ..values['api_access_token'] = 'ok'
      ..values['api_player_nickname'] = 'Lina';
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('{}', 200);
    });
    final api = WordstormApi(client: client, credentials: credentials);

    await api.ensureGuestSession('Lina');

    expect(calls, 0);
    client.close();
  });
}

class _MemoryCredentials implements ApiCredentials {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
