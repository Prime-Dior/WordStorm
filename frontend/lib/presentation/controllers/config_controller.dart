import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/api/api_client.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/room_repository.dart';
import '../../data/settings/settings_repository.dart';
import '../../domain/categories.dart';
import '../../domain/draws.dart';
import '../../domain/models/lobby_preview.dart';
import 'solo_session_controller.dart';

class ConfigController extends GetxController {
  ConfigController({required this.mode});

  final String mode;
  final RxBool randomMode = false.obs;
  final RxBool hardLetters = false.obs;
  final RxInt duration = 60.obs;
  final RxInt rounds = 3.obs;
  final RxSet<String> selected = <String>{...Categories.mandatory}.obs;
  final nicknameController = TextEditingController();
  final nickname = ''.obs;
  final nicknameError = RxnString();
  final isCreatingRoom = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNickname();
  }

  bool get isSolo => mode == 'solo';
  bool get canStart =>
      randomMode.value || Categories.isValidSelection(selected.toList());

  void toggle(String name) {
    if (randomMode.value) return;
    if (selected.contains(name)) {
      if (!Categories.mandatory.contains(name)) selected.remove(name);
    } else if (selected.length < Categories.maxPerGame) {
      selected.add(name);
    }
  }

  List<String> _categories() => List<String>.unmodifiable(
    randomMode.value ? Draws.pickRandomCategories() : selected.toList(),
  );

  Future<void> launchSolo() async {
    await Get.find<SoloSessionController>().start(
      GameSetup(
        categories: _categories(),
        durationSeconds: duration.value,
        rounds: rounds.value,
        allowHardLetters: hardLetters.value,
      ),
    );
    Get.toNamed<void>(AppRoutes.wheel);
  }

  Future<void> previewLobby() async {
    if (isCreatingRoom.value) return;

    final enteredNickname = nickname.value.trim();

    if (enteredNickname.isEmpty || enteredNickname.length > 12) {
      nicknameError.value = 'Saisis un pseudo de 1 à 12 caractères.';
      return;
    }

    nicknameError.value = null;
    isCreatingRoom.value = true;

    try {
      final authRepository = Get.find<AuthRepository>();

      // Réutilise une session déjà enregistrée.
      // Si le téléphone n'en a pas encore, crée une session invitée.
      final player =
          await authRepository.restoreSession() ??
          await authRepository.createGuestSession(enteredNickname);

      // Le serveur fait foi pour le pseudo associé au jeton.
      nickname.value = player.nickname;
      nicknameController.text = player.nickname;
      await Get.find<SettingsRepository>().setNickname(player.nickname);

      final room = await Get.find<RoomRepository>().createRoom(
        categoryMode: randomMode.value ? 'random' : 'custom',
        categories: randomMode.value ? null : selected.toList(),
        durationSeconds: duration.value,
        roundCount: rounds.value,
        allowHardLetters: hardLetters.value,
      );

      Get.toNamed<void>(
        AppRoutes.lobby,
        arguments: LobbyPreview.fromRoom(
          room: room,
          nickname: player.nickname,
          isHost: true,
        ),
      );
    } on ApiException catch (error) {
      Get.snackbar('Création impossible', error.message);
    } catch (_) {
      Get.snackbar(
        'Connexion impossible',
        'Vérifie ta connexion Internet puis réessaie.',
      );
    } finally {
      isCreatingRoom.value = false;
    }
  }

  void setNickname(String value) {
    nickname.value = value;
    if (value.trim().isNotEmpty && value.trim().length <= 12) {
      nicknameError.value = null;
    }
  }

  Future<void> _loadNickname() async {
    final saved = await Get.find<SettingsRepository>().nickname();
    if (nickname.value.isEmpty) {
      nickname.value = saved;
      nicknameController.text = saved;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  void chooseRandom() => randomMode.value = true;
  void chooseCustom() => randomMode.value = false;
  void chooseDuration(int value) => duration.value = value;
  void chooseRounds(int value) => rounds.value = value;
  void toggleHardLetters(bool value) => hardLetters.value = value;
  void back() => Get.back<void>();
}
