import '../../data/api/api_client.dart';
import '../../domain/models/player_model.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PlayerModel> createGuestSession(String nickname) async {
    final response = await _apiClient.post(
      '/auth/guest',
      authenticated: false,
      body: <String, dynamic>{'nickname': nickname.trim()},
    );

    final data = _readData(response);
    final token = data['access_token'];

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Le serveur n’a pas renvoyé de jeton de session.',
      );
    }

    await _apiClient.saveAccessToken(token);

    final rawPlayer = data['player'];
    if (rawPlayer is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Le serveur n’a pas renvoyé les informations du joueur.',
      );
    }

    return PlayerModel.fromJson(rawPlayer);
  }

  Future<PlayerModel?> restoreSession() async {
    final token = await _apiClient.readAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.get('/me');
      final data = _readData(response);
      return PlayerModel.fromJson(data);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _apiClient.deleteAccessToken();
        return null;
      }

      rethrow;
    }
  }

  Future<void> endSession() async {
    try {
      await _apiClient.delete('/session');
    } finally {
      await _apiClient.deleteAccessToken();
    }
  }

  Map<String, dynamic> _readData(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const ApiException(
      statusCode: 500,
      message: 'La réponse du serveur ne contient pas de champ data valide.',
    );
  }
}
