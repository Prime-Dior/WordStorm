import 'package:get/get.dart';

import '../../data/settings/settings_repository.dart';

/// État de présentation global, ici la préférence d'animations réduites.
class AppController extends GetxController {
  final RxBool reduceAnimations = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      reduceAnimations.value = await Get.find<SettingsRepository>()
          .reduceAnimations();
    } catch (_) {
      // Le réglage système reste appliqué si la préférence n'est pas lisible.
    }
  }

  Future<void> setReduceAnimations(bool value) async {
    reduceAnimations.value = value;
    await Get.find<SettingsRepository>().setReduceAnimations(value);
  }
}
