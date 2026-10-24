import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/letter_tile.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Écran d'accueil (maquette `#home`) — socle de la phase 1.
/// Animations de chute des lettres/flottement du héros : phase 8.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      day: true,
      showSunburst: true,
      burstTop: 0.44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + couronne + slogan + héros.
          const Expanded(
            child: Stack(
              children: [
                Positioned(left: 18, top: 40, child: WordstormLogo()),
                // Héros / tuiles flottantes : animation à la phase 8.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LetterTile(letter: 'R', size: 46, rotation: -0.42),
                        SizedBox(width: 26),
                        LetterTile(letter: 'E', size: 46, rotation: 0.31),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArcadeButton(
                label: 'Jouer',
                fontSize: 34,
                padding: const EdgeInsets.all(12),
                onPressed: () => context.push('/menu'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.66,
                child: ArcadeButton(
                  label: 'Paramètres',
                  small: true,
                  variant: ArcadeButtonVariant.dark,
                  onPressed: () => context.push('/settings'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: const ArcadeButton(
                  label: 'Quitter',
                  fontSize: 16,
                  small: true,
                  variant: ArcadeButtonVariant.dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
