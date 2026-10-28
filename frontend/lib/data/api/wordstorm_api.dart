import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_credentials.dart';

class WordstormApiException implements Exception {
  const WordstormApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

/// Client HTTP du backend. L'URL peut être remplacée au lancement par
/// `--dart-define=WORDSTORM_API_URL=https://.../api/v1`.
class WordstormApi {
  WordstormApi({
    http.Client? client,
    ApiCredentials? credentials,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _credentials = credentials ?? SecureApiCredentials(),
       _baseUrl = _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl);

  static const String _configuredBaseUrl = String.fromEnvironment(
    'WORDSTORM_API_URL',
  );

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const _tokenKey = 'api_access_token';
  static const _playerIdKey = 'api_player_id';
  static const _nicknameKey = 'api_player_nickname';
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;
  final ApiCredentials _credentials;
  final String _baseUrl;

  static String _normalizeBaseUrl(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  Future<String?> get accessToken => _credentials.read(_tokenKey);
  Future<String?> get playerId => _credentials.read(_playerIdKey);
  Future<String?> get nickname => _credentials.read(_nicknameKey);

  Future<void> createGuestSession(String playerNickname) async {
    final response = await _send(
      'POST',
      '/auth/guest',
      body: {'nickname': playerNickname.trim()},
      authenticated: false,
    );
    final data = _map(response['data']);
    final player = _map(data['player']);
    await _credentials.write(_tokenKey, data['access_token'] as String);
    await _credentials.write(_playerIdKey, '${player['id']}');
    await _credentials.write(_nicknameKey, player['nickname'] as String);
  }

  Future<void> ensureGuestSession(String playerNickname) async {
    final token = await accessToken;
    final savedNickname = await nickname;
    if (token != null &&
        token.isNotEmpty &&
        savedNickname == playerNickname.trim()) {
      return;
    }
    if (token != null && token.isNotEmpty) await clearSession();
    await createGuestSession(playerNickname);
  }

  Future<Map<String, dynamic>> createRoom({
    required bool randomCategories,
    required List<String> categories,
    required int durationSeconds,
    required int rounds,
    required bool allowHardLetters,
  }) => _send(
    'POST',
    '/rooms',
    body: {
      'category_mode': randomCategories ? 'random' : 'custom',
      if (!randomCategories) 'categories': categories,
      'duration_seconds': durationSeconds,
      'round_count': rounds,
      'allow_hard_letters': allowHardLetters,
    },
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> joinRoom(String code) => _send(
    'POST',
    '/rooms/join',
    body: {'code': code.trim().toUpperCase()},
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> getRoom(String code) => _send(
    'GET',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}',
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> startRoom(String code) => _send(
    'POST',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/start',
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> beginRound(String code, int number) => _send(
    'POST',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/rounds/$number/begin',
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> submitAnswers(
    String code,
    int number,
    Map<String, String> answers,
  ) => _send(
    'PUT',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/rounds/$number/answers',
    body: {'answers': answers},
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> getRound(String code, int number) => _send(
    'GET',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/rounds/$number',
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> lockRound(String code, int number) => _send(
    'POST',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/rounds/$number/lock',
  ).then((response) => _map(response['data']));

  Future<Map<String, dynamic>> reviewAnswer(
    String code,
    int number,
    int answerId, {
    required bool valid,
  }) => _send(
    'POST',
    '/rooms/${Uri.encodeComponent(code.toUpperCase())}/rounds/$number/answers/$answerId/review',
    body: {'valid': valid},
  ).then((response) => _map(response['data']));

  Future<void> clearSession() async {
    final token = await accessToken;
    if (token != null) {
      try {
        await _send('DELETE', '/session');
      } on WordstormApiException {
        // On efface aussi une session expirée ou déjà révoquée.
      }
    }
    await Future.wait([
      _credentials.delete(_tokenKey),
      _credentials.delete(_playerIdKey),
      _credentials.delete(_nicknameKey),
    ]);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
    };
    if (authenticated) {
      final token = await accessToken;
      if (token == null || token.isEmpty) {
        throw const WordstormApiException(
          401,
          'Crée une session joueur avant de rejoindre le salon.',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed)
          .timeout(_timeout);
      final decoded = response.bodyBytes.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WordstormApiException(
          response.statusCode,
          _errorMessage(decoded, response.statusCode),
        );
      }
      return decoded;
    } on WordstormApiException {
      rethrow;
    } on FormatException {
      throw const WordstormApiException(
        502,
        'La réponse du serveur est illisible.',
      );
    } on Exception catch (error) {
      throw WordstormApiException(0, 'Connexion à l’API impossible : $error');
    }
  }

  static String _errorMessage(Map<String, dynamic> payload, int status) {
    final message = payload['message'];
    if (message is String && message.isNotEmpty) return message;
    final errors = payload['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return '$first'.replaceAll(RegExp(r'^\[|\]$'), '');
      }
    }
    return 'Erreur de l’API ($status).';
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    throw const WordstormApiException(
      502,
      'Format de réponse inattendu du serveur.',
    );
  }
}
