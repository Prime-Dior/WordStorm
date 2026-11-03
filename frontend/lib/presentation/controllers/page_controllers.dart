import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/salon_code.dart';
import '../../data/history/history_repository.dart';
import '../../data/settings/settings_repository.dart';
import '../../domain/models/lobby_preview.dart';
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

  @override
  void onInit() {
    super.onInit();
    _loadNickname();
  }

  Future<void> submit() async {
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
    await Get.find<SettingsRepository>().setNickname(playerName);
    Get.toNamed<void>(
      '/lobby',
      arguments: LobbyPreview(
        code: normalized,
        nickname: playerName,
        isHost: false,
      ),
    );
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
