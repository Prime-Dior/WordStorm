import 'package:get/get.dart';

import '../controllers/config_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/menu_controller.dart' as page_menu;
import '../controllers/page_controllers.dart';
import '../controllers/settings_controller.dart';

/// Contrôleurs de présentation installés au moment où chaque route s'ouvre.
class HomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(HomeController.new);
}

class MenuBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(page_menu.MenuController.new);
}

class ConfigBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => ConfigController(mode: Get.parameters['mode'] ?? 'solo'),
  );
}

class WheelBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(WheelController.new);
}

class GameBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(GameController.new);
}

class RoundResultsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(RoundResultsController.new);
}

class FinalResultsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(FinalResultsController.new);
}

class JoinBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(JoinController.new);
}

class LobbyBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(LobbyController.new);
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(SettingsController.new);
}

class RulesBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(RulesController.new);
}

class HistoryBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(HistoryController.new);
}

class StatusBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(StatusController.new);
}
