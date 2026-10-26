import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/config/config_screen.dart';
import '../features/game/game_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/join/join_screen.dart';
import '../features/lobby/lobby_screen.dart';
import '../features/lobby/lobby_setup.dart';
import '../features/menu/menu_screen.dart';
import '../features/results/final_results_screen.dart';
import '../features/results/round_results_screen.dart';
import '../features/rules/rules_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/skeleton/status_screen.dart';
import '../features/wheel/wheel_screen.dart';

/// Routage de l'application (`go_router`). Chemins = flux de la maquette :
/// accueil → menu → (solo|multi) config → roue → manche → résultats de
/// manche → (roue | fin de partie). /lobby, /join, états d'erreur et
/// salon introuvable : cinéma de la phase 7 salons réels.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => _fade(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        pageBuilder: (context, state) => _fade(state, const MenuScreen()),
      ),
      GoRoute(
        path: '/config',
        name: 'config',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'solo';
          return _fade(state, ConfigScreen(mode: mode));
        },
      ),
      GoRoute(
        path: '/wheel',
        name: 'wheel',
        pageBuilder: (context, state) => _fade(state, const WheelScreen()),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        pageBuilder: (context, state) => _fade(state, const GameScreen()),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        pageBuilder: (context, state) =>
            _fade(state, const RoundResultsScreen()),
      ),
      GoRoute(
        path: '/final',
        name: 'final',
        pageBuilder: (context, state) =>
            _fade(state, const FinalResultsScreen()),
      ),
      GoRoute(
        path: '/join',
        name: 'join',
        pageBuilder: (context, state) => _fade(state, const JoinScreen()),
      ),
      GoRoute(
        path: '/lobby',
        name: 'lobby',
        pageBuilder: (context, state) => _fade(
          state,
          LobbyScreen(
            setup: state.extra is LobbySetup
                ? state.extra! as LobbySetup
                : null,
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            _overlay(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        pageBuilder: (context, state) => _overlay(state, const RulesScreen()),
      ),
      GoRoute(
        path: '/waiting',
        pageBuilder: (context, state) => _overlay(
          state,
          const StatusScreen(
            title: 'En attente d’autres joueurs…',
            message: 'En attente d’autres joueurs',
            kind: StatusKind.waiting,
          ),
        ),
      ),
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => _overlay(
          state,
          const StatusScreen(
            title: 'Ça se prépare…',
            message: 'Écran de démonstration',
            kind: StatusKind.waiting,
          ),
        ),
      ),
      GoRoute(
        path: '/connection-error',
        pageBuilder: (context, state) => _overlay(
          state,
          const StatusScreen(
            title: 'Problème de connexion',
            message: 'Vérifie ta connexion Internet et réessaie. Tes réponses restent sur l’appareil.',
            kind: StatusKind.error,
            actionLabel: 'Réessayer',
          ),
        ),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        pageBuilder: (context, state) => _fade(state, const HistoryScreen()),
      ),
      // Salon introuvable (Figma 17) : déclenché par la phase 7 quand le
      // code saisi ne correspond à aucun salon.
      GoRoute(
        path: '/not-found',
        name: 'not-found',
        pageBuilder: (context, state) => _overlay(
          state,
          const StatusScreen(
            title: 'Salon introuvable',
            message: 'Aucun salon ne correspond à ce code.',
            kind: StatusKind.error,
          ),
        ),
      ),
    ],
  );

  /// Transition douce ≈ maquette (`.s.on` : fade + scale .96, 350 ms).
  static CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(
              opacity: CurveTween(curve: Curves.easeOut).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.96,
                  end: 1,
                ).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
                child: child,
              ),
            ),
      );

  /// Route transparente qui conserve l’écran précédent sous la fenêtre.
  static CustomTransitionPage<void> _overlay(
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: const Color(0xB3121A2B),
    barrierDismissible: true,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .97, end: 1).animate(animation),
            child: child,
          ),
        ),
  );
}
