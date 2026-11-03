import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';

class HomeController extends GetxController {
  void play() => Get.toNamed<void>(AppRoutes.menu);
  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
  void quit() => SystemNavigator.pop();
}
