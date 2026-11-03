import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/letter_tile.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/home_controller.dart';

/// Première page : titre du jeu et boutons principaux.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bob = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _motion, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return ScreenScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0.0, 560.0);
          final heroHeight = (constraints.maxHeight * 0.46)
              .clamp(250.0, 380.0)
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
                      const WordstormLogo(fontSize: 38),
                      const SizedBox(height: 12),
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
                                    const SizedBox(height: 12),
                                    Text(
                                      'Joue en solo ou entre amis.',
                                      style: TextStyle(
                                        color: AppColors.offWhite.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    AnimatedBuilder(
                                      animation: _bob,
                                      child: const Row(
                                        children: [
                                          LetterTile(
                                            letter: 'R',
                                            size: 38,
                                            rotation: -0.12,
                                            middleColor: AppColors.coral,
                                            bottomColor: AppColors.coralDark,
                                            textColor: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          LetterTile(
                                            letter: 'E',
                                            size: 38,
                                            rotation: 0.1,
                                          ),
                                        ],
                                      ),
                                      builder: (context, child) =>
                                          Transform.translate(
                                            offset: Offset(
                                              0,
                                              -_bob.value * 0.35,
                                            ),
                                            child: Transform.rotate(
                                              angle: _bob.value / 180,
                                              child: child,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: AnimatedBuilder(
                                animation: _bob,
                                child: Image.asset(
                                  'assets/images/personnage_w.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerRight,
                                ),
                                builder: (context, child) =>
                                    Transform.translate(
                                      offset: Offset(0, _bob.value),
                                      child: child,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
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
          );
        },
      ),
    );
  }
}
