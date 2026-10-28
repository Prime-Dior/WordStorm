import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/audio/sound_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/page_controllers.dart';

/// Fin de partie (Figma 07/13) : en solo, le score total des manches et
/// deux actions — REJOUER (même config) et MENU. Pas de classement en
/// solo (cahier, §12 : score personnel sans palmarès).
///
/// La variante multijoueur (podium animé + confettis + départage
/// affiché égalité — Q6) est branchée à la phase 7 avec les salons.
class FinalResultsScreen extends StatefulWidget {
  const FinalResultsScreen({super.key});

  @override
  State<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends State<FinalResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Fanfare + vibration (phase 6, best-effort) : une fois par entrée
    // à l'écran (initState), pas à chaque rebuild.
    unawaited(Get.find<SoundEngine>().play(SoundCue.victory));
    unawaited(Get.find<VibrationEngine>().heavy());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinalResultsController>();
    final state = controller.session.state.value;
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
            ArcadeButton(label: 'Rejouer', onPressed: controller.replay),
            const SizedBox(height: 12),
            ArcadeButton(
              label: 'Menu',
              variant: ArcadeButtonVariant.dark,
              onPressed: controller.returnToMenu,
            ),
          ],
        ),
      ),
    );
  }
}
