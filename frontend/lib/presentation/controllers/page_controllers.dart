import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/salon_code.dart';
import '../../data/history/history_repository.dart';
import '../../domain/models/lobby_setup.dart';
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
  final error = RxnString();

  void submit() {
    final normalized = code.text.trim().toUpperCase();
    if (!SalonCode.isWellFormed(normalized)) {
      error.value = 'Code : 6 lettres/chiffres (sans 0, O, 1, I).';
      return;
    }
    error.value = null;
    Get.toNamed<void>('/lobby', parameters: {'code': normalized});
  }

  @override
  void onClose() {
    code.dispose();
    nickname.dispose();
    super.onClose();
  }
}

class LobbyController extends GetxController {
  late final LobbySetup? setup = Get.arguments as LobbySetup?;
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
