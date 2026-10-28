import 'package:get/get.dart';

import '../../data/settings/settings_repository.dart';
import 'app_controller.dart';

class SettingsController extends GetxController {
  final sound = true.obs;
  final vibration = true.obs;
  final reduceAnimations = false.obs;
  final loaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final settings = Get.find<SettingsRepository>();
    sound.value = await settings.soundOn();
    vibration.value = await settings.vibrationOn();
    reduceAnimations.value = await settings.reduceAnimations();
    loaded.value = true;
  }

  Future<void> setSound(bool value) async {
    sound.value = value;
    await Get.find<SettingsRepository>().setSoundOn(value);
  }

  Future<void> setVibration(bool value) async {
    vibration.value = value;
    await Get.find<SettingsRepository>().setVibrationOn(value);
  }

  Future<void> setReduceAnimations(bool value) async {
    reduceAnimations.value = value;
    await Get.find<AppController>().setReduceAnimations(value);
  }

  void openRules() => Get.toNamed<void>('/rules');
  void close() => Get.back<void>();
}
