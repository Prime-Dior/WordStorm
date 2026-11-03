import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';

class MenuController extends GetxController {
  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
  void openSolo() =>
      Get.toNamed<void>(AppRoutes.config, parameters: {'mode': 'solo'});
  void openMultiplayer() =>
      Get.toNamed<void>(AppRoutes.config, parameters: {'mode': 'multi'});
  void join(String code) => Get.toNamed<void>(
    AppRoutes.join,
    parameters: {'code': code.trim().toUpperCase()},
  );
  void openHistory() => Get.toNamed<void>(AppRoutes.history);
}
