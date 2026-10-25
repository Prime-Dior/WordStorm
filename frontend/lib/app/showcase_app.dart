import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/config/config_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lobby/lobby_screen.dart';
import '../features/lobby/lobby_setup.dart';
import '../features/menu/menu_screen.dart';

/// Navigation de présentation : seuls les écrans déjà travaillés sont accessibles.
class ShowcaseApp extends StatelessWidget {
  ShowcaseApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      const pagesPresentes = {'/', '/menu', '/config', '/lobby'};
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
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'WordStorm · écrans réalisés',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    routerConfig: _router,
    builder: (context, child) =>
        _PhonePreview(child: child ?? const SizedBox()),
  );
}

/// Cadre téléphone pour comparer les écrans sur ordinateur.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);
    const phoneSize = Size(390, 844);

    return ColoredBox(
      color: const Color(0xFF151925),
      child: Center(
        child: FittedBox(
          child: Container(
            width: 414,
            height: 868,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF080A0F),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: const Color(0xFF454955), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 34,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(37),
              child: SizedBox(
                width: phoneSize.width,
                height: phoneSize.height,
                child: MediaQuery(
                  data: screen.copyWith(
                    size: phoneSize,
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),
                      Align(
                        alignment: Alignment.topCenter,
                        child: IgnorePointer(
                          child: Container(
                            width: 112,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFF080A0F),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
