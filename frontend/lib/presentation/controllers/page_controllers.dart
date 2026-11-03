import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/salon_code.dart';
import '../../data/api/api_client.dart';
import '../../data/history/history_repository.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/room_repository.dart';
import '../../data/settings/settings_repository.dart';
import '../../domain/models/lobby_preview.dart';
import '../../domain/models/multiplayer_round_session.dart';
import '../../domain/models/room_model.dart';
import '../../domain/models/round_model.dart';
import 'solo_session_controller.dart';

class WheelController extends GetxController {
  final session = Get.find<SoloSessionController>();
}

class GameController extends GetxController {
  final session = Get.find<SoloSessionController>();

  Future<void> finishTurn(Map<String, String> answers) async {
    for (final entry in answers.entries) {
      session.setAnswer(entry.key, entry.value);
    }
    await session.endTurn();
  }
}

class RoundResultsController extends GetxController {
  final session = Get.find<SoloSessionController>();
}

class FinalResultsController extends GetxController {
  final session = Get.find<SoloSessionController>();

  Future<void> replay() async {
    await session.restart();
    Get.offNamed<void>('/wheel');
  }

  void returnToMenu() => Get.offNamed<void>('/menu');
}

class JoinController extends GetxController {
  final code = TextEditingController();
  final nickname = TextEditingController();
  final codeError = RxnString();
  final nicknameError = RxnString();
  final isJoining = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNickname();
  }

  Future<void> submit() async {
    if (isJoining.value) return;

    final normalized = SalonCode.normalized(code.text);
    if (!SalonCode.isWellFormed(normalized)) {
      codeError.value = 'Code : 6 lettres/chiffres (sans 0, O, 1, I).';
      return;
    }
    codeError.value = null;

    final playerName = nickname.text.trim();
    if (playerName.isEmpty || playerName.length > 12) {
      nicknameError.value = 'Saisis un pseudo de 1 à 12 caractères.';
      return;
    }

    codeError.value = null;
    nicknameError.value = null;
    isJoining.value = true;

    try {
      final auth = Get.find<AuthRepository>();
      final player =
          await auth.restoreSession() ??
          await auth.createGuestSession(playerName);

      nickname.text = player.nickname;
      await Get.find<SettingsRepository>().setNickname(player.nickname);
      final room = await Get.find<RoomRepository>().joinRoom(normalized);

      Get.toNamed<void>(
        '/lobby',
        arguments: LobbyPreview.fromRoom(
          room: room,
          nickname: player.nickname,
          isHost: false,
        ),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        codeError.value = 'Aucun salon ne correspond à ce code.';
      } else {
        Get.snackbar('Impossible de rejoindre', error.message);
      }
    } catch (_) {
      Get.snackbar(
        'Connexion impossible',
        'Vérifie ta connexion Internet puis réessaie.',
      );
    } finally {
      isJoining.value = false;
    }
  }

  Future<void> _loadNickname() async {
    final saved = await Get.find<SettingsRepository>().nickname();
    if (nickname.text.isEmpty) nickname.text = saved;
  }

  void onCodeChanged(String value) {
    codeError.value = null;
  }

  @override
  void onClose() {
    code.dispose();
    nickname.dispose();
    super.onClose();
  }
}

class LobbyController extends GetxController {
  late final LobbyPreview? preview = Get.arguments as LobbyPreview?;
  final room = Rxn<RoomModel>();
  final isLoading = true.obs;
  final isStarting = false.obs;
  final error = RxnString();

  Timer? _pollingTimer;
  int? _openedRoundNumber;
  bool _requestInProgress = false;

  String get code => room.value?.code ?? preview?.code ?? '';
  String get nickname => preview?.nickname ?? 'Joueur';
  bool get isHost => preview?.isHost ?? false;

  @override
  void onInit() {
    super.onInit();
    refreshRoom();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => refreshRoom(silent: true),
    );
  }

  Future<void> refreshRoom({bool silent = false}) async {
    if (_requestInProgress || code.isEmpty) return;
    _requestInProgress = true;

    try {
      final latest = await Get.find<RoomRepository>().getRoom(code);
      room.value = latest;
      error.value = null;
      isLoading.value = false;
      _openActiveRound(latest);
    } on ApiException catch (exception) {
      if (!silent) error.value = exception.message;
      isLoading.value = false;
    } catch (_) {
      if (!silent) error.value = 'Impossible de charger le salon.';
      isLoading.value = false;
    } finally {
      _requestInProgress = false;
    }
  }

  Future<void> startGame() async {
    if (isStarting.value || !isHost) return;
    isStarting.value = true;

    try {
      final started = await Get.find<RoomRepository>().startRoom(code);
      room.value = started;
      final firstRound = await Get.find<RoomRepository>().beginRound(code, 1);
      _openRound(started, firstRound);
    } on ApiException catch (exception) {
      Get.snackbar('Démarrage impossible', exception.message);
    } catch (_) {
      Get.snackbar(
        'Connexion impossible',
        'Vérifie ta connexion Internet puis réessaie.',
      );
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> leaveRoom() async {
    _pollingTimer?.cancel();

    try {
      await Get.find<RoomRepository>().leaveRoom(code);
    } on ApiException catch (exception) {
      Get.snackbar('Départ du salon', exception.message);
    } catch (_) {
      Get.snackbar('Départ du salon', 'Le salon n’a pas pu être quitté.');
    } finally {
      Get.offAllNamed<void>('/menu');
    }
  }

  void _openActiveRound(RoomModel currentRoom) {
    if (currentRoom.status != 'in_progress') return;

    final activeRounds = currentRoom.rounds
        .where((round) => round.status == 'active')
        .toList(growable: false);
    if (activeRounds.isEmpty) return;
    final activeRound = activeRounds.first;
    if (activeRound.number == _openedRoundNumber) return;

    _openRound(currentRoom, activeRound);
  }

  void _openRound(RoomModel currentRoom, RoundModel round) {
    if (_openedRoundNumber == round.number) return;
    _openedRoundNumber = round.number;
    Get.offNamed<void>(
      '/multiplayer-game',
      arguments: MultiplayerRoundSession.fromRoom(
        room: currentRoom,
        round: round,
        nickname: nickname,
        isHost: isHost,
      ),
    );
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}

class RulesController extends GetxController {
  void close() => Get.back<void>();
}

class HistoryController extends GetxController {
  final records = <GameRecord>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    records.assignAll(await Get.find<HistoryRepository>().all());
    isLoading.value = false;
  }

  Future<void> clear() async {
    await Get.find<HistoryRepository>().clear();
    records.clear();
  }
}

class StatusController extends GetxController {
  void close() => Get.back<void>();

  void open(String route) => Get.toNamed<void>(route);
}
