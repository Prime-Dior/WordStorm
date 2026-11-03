import '../../domain/models/room_model.dart';
import '../../domain/models/round_model.dart';
import '../api/api_client.dart';

class RoomRepository {
  RoomRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<RoomModel> createRoom({
    required String categoryMode,
    required int durationSeconds,
    required int roundCount,
    required bool allowHardLetters,
    List<String>? categories,
  }) async {
    final body = <String, dynamic>{
      'category_mode': categoryMode,
      'duration_seconds': durationSeconds,
      'round_count': roundCount,
      'allow_hard_letters': allowHardLetters,
    };

    if (categoryMode == 'custom') {
      body['categories'] = categories ?? const <String>[];
    }

    final response = await _apiClient.post('/rooms', body: body);
    return RoomModel.fromJson(_readData(response));
  }

  Future<RoomModel> joinRoom(String code) async {
    final response = await _apiClient.post(
      '/rooms/join',
      body: <String, dynamic>{'code': code.trim().toUpperCase()},
    );

    return RoomModel.fromJson(_readData(response));
  }

  Future<RoomModel> getRoom(String code) async {
    final response = await _apiClient.get('/rooms/${_safeCode(code)}');
    return RoomModel.fromJson(_readData(response));
  }

  Future<List<Map<String, dynamic>>> getFinalResults(String code) async {
    final response = await _apiClient.get('/rooms/${_safeCode(code)}/results');
    final data = _readData(response);
    final results = data['results'];
    if (results is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Le serveur n’a pas renvoyé le classement final.',
      );
    }
    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<RoomModel> startRoom(String code) async {
    final response = await _apiClient.post('/rooms/${_safeCode(code)}/start');
    return RoomModel.fromJson(_readData(response));
  }

  Future<RoundModel> beginRound(String code, int roundNumber) async {
    final response = await _apiClient.post(
      '/rooms/${_safeCode(code)}/rounds/$roundNumber/begin',
    );

    return RoundModel.fromJson(_readData(response));
  }

  Future<RoundModel> getRound(String code, int roundNumber) async {
    final response = await _apiClient.get(
      '/rooms/${_safeCode(code)}/rounds/$roundNumber',
    );

    return RoundModel.fromJson(_readData(response));
  }

  Future<RoundModel> submitAnswers(
    String code,
    int roundNumber,
    Map<String, String?> answers,
  ) async {
    final response = await _apiClient.put(
      '/rooms/${_safeCode(code)}/rounds/$roundNumber/answers',
      body: <String, dynamic>{'answers': answers},
    );

    return RoundModel.fromJson(_readData(response));
  }

  Future<RoundModel> lockRound(String code, int roundNumber) async {
    final response = await _apiClient.post(
      '/rooms/${_safeCode(code)}/rounds/$roundNumber/lock',
    );

    return RoundModel.fromJson(_readData(response));
  }

  Future<void> leaveRoom(String code) async {
    await _apiClient.delete('/rooms/${_safeCode(code)}/leave');
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

  String _safeCode(String code) {
    return Uri.encodeComponent(code.trim().toUpperCase());
  }
}
