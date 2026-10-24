import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/skeleton/placeholder_screen.dart';

/// Routage de l'application (`go_router`), avec transitions propres aux
/// phases 4 et 8. Les routes correspondent au flux de la maquette :
/// accueil → menu → (solo|multi) → config → salon → tirage → manche →
/// fin de manche → résultats (→ menu).
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) =>
            _fade(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        pageBuilder: (context, state) =>
            _fade(context, state, const MenuScreen()),
      ),
      GoRoute(
        path: '/config',
        name: 'config',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          PlaceholderScreen(
            title: 'Nouvelle partie',
            route: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: '/join',
        name: 'join',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          PlaceholderScreen(
            title: 'Rejoindre un salon',
            route: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: '/lobby',
        name: 'lobby',
        pageBuilder: (context, state) =>
            _fade(context, state, const PlaceholderScreen(title: 'Salon')),
      ),
      GoRoute(
        path: '/wheel',
        name: 'wheel',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          const PlaceholderScreen(title: 'Tirage de la lettre'),
        ),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          const PlaceholderScreen(title: 'Manche en cours'),
        ),
      ),
      GoRoute(
        path: '/turn-end',
        name: 'turn-end',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          const PlaceholderScreen(title: 'Fin de la manche'),
        ),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        pageBuilder: (context, state) =>
            _fade(context, state, const PlaceholderScreen(title: 'Résultats')),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            _fade(context, state, const PlaceholderScreen(title: 'Paramètres')),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        pageBuilder: (context, state) => _fade(
          context,
          state,
          const PlaceholderScreen(title: 'Règles du jeu'),
        ),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        pageBuilder: (context, state) =>
            _fade(context, state, const PlaceholderScreen(title: 'Historique')),
      ),
    ],
  );

  /// Transition douce ≈ décalage de la maquette (`.s.on` : fade + scale .96).
  static CustomTransitionPage<void> _fade(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<void>(
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
}
