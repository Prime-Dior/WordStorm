import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/lobby_preview.dart';
import '../../domain/models/multiplayer_round_session.dart';
import '../../presentation/bindings/page_bindings.dart';
import '../../presentation/pages/config/config_page.dart';
import '../../presentation/pages/final_results/final_results_page.dart';
import '../../presentation/pages/game/game_page.dart';
import '../../presentation/pages/game/time_up_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/join/join_page.dart';
import '../../presentation/pages/lobby/lobby_page.dart';
import '../../presentation/pages/menu/menu_page.dart';
import '../../presentation/pages/multiplayer_game/multiplayer_game_page.dart';
import '../../presentation/pages/podium/podium_page.dart';
import '../../presentation/pages/results/round_results_page.dart';
import '../../presentation/pages/rules/rules_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/wheel/wheel_page.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.menu,
      page: () => const MenuScreen(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.config,
      page: () => ConfigScreen(mode: Get.parameters['mode'] ?? 'solo'),
      binding: ConfigBinding(),
    ),
    GetPage(
      name: AppRoutes.wheel,
      page: () => const WheelScreen(),
      binding: WheelBinding(),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameScreen(),
      binding: GameBinding(),
    ),
    GetPage(name: AppRoutes.timeUp, page: () => const TimeUpScreen()),
    GetPage(
      name: AppRoutes.multiplayerGame,
      page: () => Get.arguments is MultiplayerRoundSession
          ? const MultiplayerGameScreen()
          : const MissingMultiplayerGameSessionScreen(),
      binding: MultiplayerGameBinding(),
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => const RoundResultsScreen(),
      binding: RoundResultsBinding(),
    ),
    GetPage(
      name: AppRoutes.finalResults,
      page: () => const FinalResultsScreen(),
      binding: FinalResultsBinding(),
    ),
    GetPage(name: AppRoutes.podium, page: () => const PodiumScreen()),
    GetPage(
      name: AppRoutes.join,
      page: () => const JoinScreen(),
      binding: JoinBinding(),
    ),
    GetPage(
      name: AppRoutes.lobby,
      page: () => LobbyScreen(preview: Get.arguments as LobbyPreview?),
      binding: LobbyBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => _overlay(const SettingsScreen()),
      binding: SettingsBinding(),
      opaque: false,
    ),
    GetPage(
      name: AppRoutes.rules,
      page: () => _overlay(const RulesScreen()),
      binding: RulesBinding(),
      opaque: false,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      binding: HistoryBinding(),
    ),
  ];

  static Widget _overlay(Widget child) => Stack(
    fit: StackFit.expand,
    children: [
      GestureDetector(
        onTap: Get.back<void>,
        child: const ColoredBox(color: Color(0xB3121A2B)),
      ),
      Center(child: child),
    ],
  );
}
