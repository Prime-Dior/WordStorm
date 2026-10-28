import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';

class MenuController extends GetxController {
  final codeController = TextEditingController();

  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
  void openSolo() =>
      Get.toNamed<void>(AppRoutes.config, parameters: {'mode': 'solo'});
  void openMultiplayer() =>
      Get.toNamed<void>(AppRoutes.config, parameters: {'mode': 'multi'});
  void join() => Get.toNamed<void>(AppRoutes.join);
  void openHistory() => Get.toNamed<void>(AppRoutes.history);

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
