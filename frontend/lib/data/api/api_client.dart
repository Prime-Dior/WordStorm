import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, FlutterSecureStorage? secureStorage})
    : _httpClient = httpClient ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'wordstorm.access_token';

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteAccessToken() {
    return _secureStorage.delete(key: _tokenKey);
  }

  Future<Map<String, dynamic>> get(String path, {bool authenticated = true}) {
    return _send('GET', path, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send('POST', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send('PUT', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = true,
  }) {
    return _send('DELETE', path, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${ApiConfig.baseUrl}$normalizedPath');

    final headers = <String, String>{'Accept': 'application/json'};

    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final token = await readAccessToken();

      if (token == null || token.isEmpty) {
        throw const ApiException(
          statusCode: 401,
          message: 'Aucune session active. Crée une session joueur.',
        );
      }

      headers['Authorization'] = 'Bearer $token';
    }

    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await _httpClient.get(uri, headers: headers);
      case 'POST':
        response = await _httpClient.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'PUT':
        response = await _httpClient.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'DELETE':
        response = await _httpClient.delete(uri, headers: headers);
      default:
        throw ArgumentError.value(method, 'method', 'Méthode HTTP inconnue.');
    }

    if (response.body.trim().isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return <String, dynamic>{};
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'La requête a échoué (${response.statusCode}).',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'La réponse du serveur n’est pas un JSON valide.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Format de réponse serveur inattendu.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _messageFromResponse(decoded, response.statusCode),
        details: decoded['errors'],
      );
    }

    return decoded;
  }

  String _messageFromResponse(Map<String, dynamic> json, int statusCode) {
    final errors = json['errors'];

    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    final message = json['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'La requête a échoué ($statusCode).';
  }

  void close() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  final int statusCode;
  final String message;
  final Object? details;

  @override
  String toString() => message;
}
