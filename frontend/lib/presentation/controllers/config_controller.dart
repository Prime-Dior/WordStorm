import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../domain/categories.dart';
import '../../domain/draws.dart';
import '../../domain/models/lobby_setup.dart';
import 'solo_session_controller.dart';

class ConfigController extends GetxController {
  ConfigController({required this.mode});

  final String mode;
  final RxBool randomMode = false.obs;
  final RxBool hardLetters = false.obs;
  final RxInt duration = 60.obs;
  final RxInt rounds = 3.obs;
  final RxSet<String> selected = <String>{...Categories.mandatory}.obs;

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

  void previewLobby() => Get.toNamed<void>(
    AppRoutes.lobby,
    arguments: LobbySetup(
      categories: _categories(),
      durationSeconds: duration.value,
      rounds: rounds.value,
      allowHardLetters: hardLetters.value,
      randomCategories: randomMode.value,
    ),
  );

  void chooseRandom() => randomMode.value = true;
  void chooseCustom() => randomMode.value = false;
  void chooseDuration(int value) => duration.value = value;
  void chooseRounds(int value) => rounds.value = value;
  void toggleHardLetters(bool value) => hardLetters.value = value;
  void back() => Get.back<void>();
}
