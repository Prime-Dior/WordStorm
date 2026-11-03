import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/letter_tile.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      margin: const EdgeInsets.only(bottom: 22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.offWhite.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.yellow.withValues(alpha: 0.7),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.45,
                          child: Image.asset(
                            'assets/images/avatar_toi.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const WordstormLogo(fontSize: 38),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LetterTile(letter: 'W', size: 34),
                        SizedBox(width: 8),
                        LetterTile(letter: 'S', size: 34),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Un jeu de mots entre amis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.offWhite.withValues(alpha: 0.78),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ArcadeButton(label: 'Jouer', onPressed: controller.play),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ArcadeButton(
                            label: 'Paramètres',
                            small: true,
                            variant: ArcadeButtonVariant.dark,
                            onPressed: controller.openSettings,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ArcadeButton(
                            label: 'Quitter',
                            small: true,
                            variant: ArcadeButtonVariant.dark,
                            onPressed: controller.quit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
