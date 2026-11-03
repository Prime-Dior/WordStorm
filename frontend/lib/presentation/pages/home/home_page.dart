import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/home_controller.dart';

/// Première page : titre du jeu et boutons principaux.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return ScreenScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0.0, 560.0);
          final heroHeight = (constraints.maxHeight * 0.43)
              .clamp(300.0, 360.0)
              .toDouble();

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: WordstormLogo(width: width * 0.58),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: heroHeight,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Des mots,\nun seul\nchampion !',
                                      style: TextStyle(
                                        color: AppColors.offWhite,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        height: 1.15,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Joue en solo ou entre amis.',
                                      style: TextStyle(
                                        color: AppColors.offWhite.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/home_letter_r.png',
                                          width: 56,
                                          height: 56,
                                        ),
                                        const SizedBox(width: 12),
                                        Image.asset(
                                          'assets/images/home_letter_e.png',
                                          width: 56,
                                          height: 56,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.92, end: 1),
                                duration: const Duration(milliseconds: 650),
                                curve: Curves.easeOutBack,
                                child: Image.asset(
                                  'assets/images/personnage_w.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerRight,
                                ),
                                builder: (context, scale, child) =>
                                    Transform.scale(scale: scale, child: child),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: width,
                        child: ArcadeButton(
                          label: 'Jouer',
                          onPressed: controller.play,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FractionallySizedBox(
                        widthFactor: 0.66,
                        child: ArcadeButton(
                          label: 'Paramètres',
                          small: true,
                          variant: ArcadeButtonVariant.dark,
                          onPressed: controller.openSettings,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ArcadeButton(
                          label: 'Quitter',
                          small: true,
                          variant: ArcadeButtonVariant.dark,
                          onPressed: controller.quit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
