import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/lobby_setup.dart';
import '../../presentation/bindings/page_bindings.dart';
import '../../presentation/pages/config/config_page.dart';
import '../../presentation/pages/final_results/final_results_page.dart';
import '../../presentation/pages/game/game_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/join/join_page.dart';
import '../../presentation/pages/lobby/lobby_page.dart';
import '../../presentation/pages/menu/menu_page.dart';
import '../../presentation/pages/results/round_results_page.dart';
import '../../presentation/pages/rules/rules_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/status/status_page.dart';
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
    GetPage(
      name: AppRoutes.join,
      page: () => const JoinScreen(),
      binding: JoinBinding(),
    ),
    GetPage(
      name: AppRoutes.lobby,
      page: () => LobbyScreen(setup: Get.arguments as LobbySetup?),
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
    GetPage(
      name: AppRoutes.waiting,
      page: () => _overlay(
        const StatusScreen(
          title: 'En attente d’autres joueurs…',
          message: 'En attente d’autres joueurs',
          kind: StatusKind.waiting,
        ),
      ),
      binding: StatusBinding(),
      opaque: false,
    ),
    GetPage(
      name: AppRoutes.loading,
      page: () => _overlay(
        const StatusScreen(
          title: 'Ça se prépare…',
          message: 'Écran de démonstration',
          kind: StatusKind.waiting,
        ),
      ),
      binding: StatusBinding(),
      opaque: false,
    ),
    GetPage(
      name: AppRoutes.connectionError,
      page: () => _overlay(
        const StatusScreen(
          title: 'Problème de connexion',
          message: 'Vérifie ta connexion Internet et réessaie. Tes réponses restent sur l’appareil.',
          kind: StatusKind.error,
          actionLabel: 'Réessayer',
        ),
      ),
      binding: StatusBinding(),
      opaque: false,
    ),
    GetPage(
      name: AppRoutes.notFound,
      page: () => _overlay(
        const StatusScreen(
          title: 'Salon introuvable',
          message: 'Aucun salon ne correspond à ce code.',
          kind: StatusKind.error,
        ),
      ),
      binding: StatusBinding(),
      opaque: false,
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
