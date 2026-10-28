import 'dart:async';

import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/salon_code.dart';
import '../../data/api/multiplayer_session.dart';
import '../../data/api/wordstorm_api.dart';

class MultiplayerController extends GetxController {
  final api = Get.find<WordstormApi>();
  final session = Rxn<MultiplayerSession>();
  final room = <String, dynamic>{}.obs;
  final round = <String, dynamic>{}.obs;
  final busy = false.obs;
  final error = RxnString();
  Timer? _poll;
  Timer? _resultPoll;
  bool _refreshing = false;

  Future<void> createRoom({
    required String nickname,
    required bool randomCategories,
    required List<String> categories,
    required int durationSeconds,
    required int rounds,
    required bool allowHardLetters,
  }) async {
    await _run(() async {
      await api.ensureGuestSession(nickname);
      final raw = await api.createRoom(
        randomCategories: randomCategories,
        categories: categories.map(categoryToApi).toList(growable: false),
        durationSeconds: durationSeconds,
        rounds: rounds,
        allowHardLetters: allowHardLetters,
      );
      _acceptRoom(raw, isHost: true);
      Get.toNamed<void>(AppRoutes.lobby);
      _startPolling();
    });
  }

  Future<void> joinRoom(String code, String nickname) async {
    if (!SalonCode.isWellFormed(code.trim().toUpperCase())) {
      error.value = 'Code : 6 lettres/chiffres (sans 0, O, 1, I).';
      return;
    }
    await _run(() async {
      await api.ensureGuestSession(nickname);
      final raw = await api.joinRoom(code);
      _acceptRoom(raw, isHost: false);
      Get.offNamed<void>(AppRoutes.lobby);
      _startPolling();
    });
  }

  Future<void> refreshRoom() async {
    final current = session.value;
    if (current == null || busy.value || _refreshing) return;
    _refreshing = true;
    try {
      final raw = await api.getRoom(current.code);
      final mappedRoom = mapApiRoom(raw, isHost: current.isHost);
      room.assignAll(mappedRoom.toMap());
      final rounds = mappedRoom.rounds;
      final started = rounds.cast<Map>().cast<Map<String, dynamic>>().where(
        (item) => item['status'] == 'active',
      );
      if (started.isNotEmpty) {
        await loadRound((started.first['number'] as num).toInt());
      }
    } on WordstormApiException catch (e) {
      error.value = e.message;
    } finally {
      _refreshing = false;
    }
  }

  Future<void> startGame() async {
    final current = session.value;
    if (current == null) return;
    await _run(() async {
      final raw = await api.startRoom(current.code);
      room.assignAll(mapApiRoom(raw, isHost: current.isHost).toMap());
    });
  }

  Future<void> beginRound(int number) async {
    final current = session.value;
    if (current == null || !current.isHost) return;
    await _run(() async => api.beginRound(current.code, number));
    if (error.value == null) await loadRound(number);
  }

  Future<void> loadRound(int number) async {
    final current = session.value;
    if (current == null) return;
    final raw = await api.getRound(current.code, number);
    round.assignAll(raw);
    _poll?.cancel();
  }

  Future<void> submitAnswers(Map<String, String> answers) async {
    final current = session.value;
    final number = (round['number'] as num?)?.toInt();
    if (current == null || number == null || round['status'] != 'active') {
      return;
    }
    try {
      final saved = await api.submitAnswers(
        current.code,
        number,
        answers.map((key, value) => MapEntry(categoryToApi(key), value)),
      );
      round.assignAll(saved);
    } on WordstormApiException catch (e) {
      error.value = e.message;
    }
  }

  Future<void> finishRound(Map<String, String> answers) async {
    final current = session.value;
    final number = (round['number'] as num?)?.toInt();
    if (current == null || number == null) return;
    await _run(() async {
      await api.submitAnswers(
        current.code,
        number,
        answers.map((key, value) => MapEntry(categoryToApi(key), value)),
      );
      try {
        await api.lockRound(current.code, number);
      } on WordstormApiException catch (e) {
        // Avant l'échéance, le prochain appel de l'hôte pourra clôturer.
        if (e.statusCode != 403 && e.statusCode != 409) rethrow;
      }
      final finalRound = await api.getRound(current.code, number);
      round.assignAll(finalRound);
      if (finalRound['status'] != 'completed') {
        _resultPoll?.cancel();
        _resultPoll = Timer.periodic(const Duration(seconds: 2), (_) async {
          try {
            try {
              await api.lockRound(current.code, number);
            } on WordstormApiException catch (e) {
              if (e.statusCode != 403 && e.statusCode != 409) rethrow;
            }
            final latest = await api.getRound(current.code, number);
            round.assignAll(latest);
            if (latest['status'] == 'completed') {
              _resultPoll?.cancel();
            }
          } on WordstormApiException catch (e) {
            error.value = e.message;
          }
        });
        return;
      }
      _startPolling();
    });
  }

  Future<void> nextRound() async {
    final current = session.value;
    final number = (round['number'] as num?)?.toInt();
    if (current == null || number == null) return;
    if (number >= current.setup.rounds) {
      leaveToMenu();
      return;
    }
    if (current.isHost) {
      await beginRound(number + 1);
    }
    _startPolling();
  }

  Future<void> review(int answerId, {required bool valid}) async {
    final current = session.value;
    final number = (round['number'] as num?)?.toInt();
    if (current == null || number == null || !current.isHost) return;
    await _run(() async {
      final updated = await api.reviewAnswer(
        current.code,
        number,
        answerId,
        valid: valid,
      );
      round.assignAll(updated);
    });
  }

  void _acceptRoom(Map<String, dynamic> raw, {required bool isHost}) {
    final mapped = mapApiRoom(raw, isHost: isHost);
    session.value = MultiplayerSession(
      code: mapped.code,
      setup: mapped.setup,
      isHost: isHost,
    );
    room.assignAll(mapped.toMap());
    error.value = null;
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => refreshRoom());
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy.value) return;
    busy.value = true;
    error.value = null;
    try {
      await action();
    } on WordstormApiException catch (e) {
      error.value = e.message;
    } finally {
      busy.value = false;
    }
  }

  void leaveToMenu() {
    _poll?.cancel();
    _resultPoll?.cancel();
    session.value = null;
    room.clear();
    round.clear();
    Get.offAllNamed<void>(AppRoutes.menu);
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}
