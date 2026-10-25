import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/audio/sound_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Fin de partie (Figma 07/13) : en solo, le score total des manches et
/// deux actions — REJOUER (même config) et MENU. Pas de classement en
/// solo (cahier, §12 : score personnel sans palmarès).
///
/// La variante multijoueur (podium animé + confettis + départage
/// affiché égalité — Q6) est branchée à la phase 7 avec les salons.
class FinalResultsScreen extends ConsumerStatefulWidget {
  const FinalResultsScreen({super.key});

  @override
  ConsumerState<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends ConsumerState<FinalResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Fanfare + vibration (phase 6, best-effort) : une fois par entrée
    // à l'écran (initState), pas à chaque rebuild.
    unawaited(ref.read(soundEngineProvider).play(SoundCue.victory));
    unawaited(ref.read(vibrationProvider).heavy());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soloSessionProvider);
    final total = state.roundHistory.fold(
      0,
      (sum, round) => sum + round.score.totalFor('solo'),
    );
    final rounds = state.roundHistory.length;

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.3,
      skylineHeight: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WordstormLogoSmall(),
            const SizedBox(height: 30),
            const Text(
              'PARTIE TERMINÉE',
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 34,
                color: AppColors.yellow,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ton score en $rounds manche${rounds > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$total',
              style: const TextStyle(
                fontFamily: AppTheme.monoFont,
                fontSize: 72,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 34),
            ArcadeButton(
              label: 'Rejouer',
              onPressed: () async {
                // Réinitialise mots consommés/manches, garde la config.
                final notifier = ref.read(soloSessionProvider.notifier);
                await notifier.restart();
                if (context.mounted) context.pushReplacement('/wheel');
              },
            ),
            const SizedBox(height: 12),
            ArcadeButton(
              label: 'Menu',
              variant: ArcadeButtonVariant.dark,
              onPressed: () => context.pushReplacement('/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
