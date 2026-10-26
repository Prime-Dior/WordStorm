import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

/// Racine de l'application : thème Wordstorm et navigation `go_router`
/// (enveloppé dans ProviderScope par `main.dart`).
///
/// La promesse applicative « Réduire les animations » (phase 3) est
/// appliquée ici : elle est **fusionnée** avec le réglage système
/// (`MediaQuery.disableAnimations`) pour toute la sous-arborescence —
/// wheel et Sunburst consultent `MediaQuery` (phase 6).
class WordstormApp extends ConsumerStatefulWidget {
  const WordstormApp({super.key, this.desktopViewport = false});

  /// Sur ordinateur : centre l'application dans une colonne de la
  /// largeur d'un téléphone (présentation).
  final bool desktopViewport;

  @override
  ConsumerState<WordstormApp> createState() => _WordstormAppState();
}

class _WordstormAppState extends ConsumerState<WordstormApp> {
  bool _reduceAnimations = false;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    try {
      final reduce = await ref.read(settingsProvider).reduceAnimations();
      if (mounted && reduce != _reduceAnimations) {
        setState(() => _reduceAnimations = reduce);
      }
    } catch (_) {
      // Best-effort : pas de réglage lisible (tests/plateforme) →
      // comportement système seul.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wordstorm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
      // Fusion réglage système ∪ réglage applicatif (jamais de
      // réactivation d'animations si le système les réduit).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final content = MediaQuery(
          data: mq.copyWith(
            disableAnimations: mq.disableAnimations || _reduceAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        );
        if (!widget.desktopViewport) return content;
        return ColoredBox(
          color: const Color(0xFF151925),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
