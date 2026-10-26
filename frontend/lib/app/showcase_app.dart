import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/config/config_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lobby/lobby_screen.dart';
import '../features/lobby/lobby_setup.dart';
import '../features/menu/menu_screen.dart';
import '../features/rules/rules_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/skeleton/status_screen.dart';

/// Navigation de présentation : seuls les écrans déjà travaillés sont accessibles.
class ShowcaseApp extends StatelessWidget {
  ShowcaseApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      const pagesPresentes = {
        '/',
        '/menu',
        '/config',
        '/lobby',
        '/settings',
        '/rules',
        '/waiting',
        '/loading',
        '/connection-error',
        '/not-found',
      };
      if (!pagesPresentes.contains(state.uri.path)) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
      GoRoute(
        path: '/config',
        builder: (context, state) =>
            ConfigScreen(mode: state.uri.queryParameters['mode'] ?? 'solo'),
      ),
      GoRoute(
        path: '/lobby',
        builder: (context, state) => LobbyScreen(
          setup: state.extra is LobbySetup ? state.extra! as LobbySetup : null,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _showcaseOverlay(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/rules',
        pageBuilder: (context, state) =>
            _showcaseOverlay(state, const RulesScreen()),
      ),
      GoRoute(
        path: '/waiting',
        pageBuilder: (context, state) => _showcaseOverlay(
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
        pageBuilder: (context, state) => _showcaseOverlay(
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
        pageBuilder: (context, state) => _showcaseOverlay(
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
        path: '/not-found',
        pageBuilder: (context, state) => _showcaseOverlay(
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

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'WordStorm · écrans réalisés',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    routerConfig: _router,
    builder: (context, child) =>
        _ShowcaseViewport(child: child ?? const SizedBox()),
  );
}

CustomTransitionPage<void> _showcaseOverlay(
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
      FadeTransition(opacity: animation, child: child),
);

/// Présentation centrée pour ordinateur, sans cadre de téléphone.
class _ShowcaseViewport extends StatelessWidget {
  const _ShowcaseViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF151925),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
    );
  }
}
