import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/letter_tile.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Écran d'accueil (maquette `#home`) — recadré à la maquette v4 :
/// logo en haut-gauche, slogan, héros, tuiles flottantes R/E colorées,
/// boutons empilés à largeur 100%/66%/50%.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Fond et décor de l'écran d'accueil.
    return ScreenScaffold(
      day: true,
      showSunburst: true,
      burstTop: 0.44,
      skylineHeight: 320,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Logo et petite phrase d'accueil.
          const Positioned(
            left: 18,
            top: 76,
            child: WordstormLogo(showLightning: true),
          ),
          // Slogan « Des mots, un seul champion ! ».
          Positioned(
            left: 18,
            top: size.height * 0.37,
            child: const Text(
              'Des mots,\nun seul champion !',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Color(0xFF1E2A44),
                shadows: [
                  Shadow(color: Color(0xCCFFFFFF), offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
          // Illustration principale.
          Positioned(
            right: -20,
            bottom: size.height * 0.33,
            child: Image.asset(
              'assets/images/personnage_w.png',
              width: size.width * 0.73,
              fit: BoxFit.contain,
            ),
          ),
          // Quelques lettres pour rappeler le principe du jeu.
          Positioned(
            left: 18,
            bottom: size.height * 0.44,
            child: Transform.rotate(
              angle: -0.42,
              child: const LetterTile(
                letter: 'R',
                size: 46,
                rotation: -0.42,
                topColor: Color(0xFFFF9A9D),
                middleColor: Color(0xFFFF747A),
                bottomColor: Color(0xFFFF5A5F),
                shadowColor: Color(0xFFB93A3E),
                textColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 88,
            // La tuile reste au-dessus des boutons et se voit à côté du R.
            bottom: size.height * 0.34,
            child: Transform.rotate(
              angle: 0.31,
              child: const LetterTile(letter: 'E', size: 46, rotation: 0.31),
            ),
          ),
          // Accès au menu, aux réglages et sortie de l'application.
          Positioned(
            left: 18,
            right: 18,
            bottom: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ArcadeButton(
                  label: 'Jouer',
                  fontSize: 34,
                  padding: const EdgeInsets.all(12),
                  onPressed: () => context.push('/menu'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.17),
                  child: ArcadeButton(
                    label: 'Paramètres',
                    small: true,
                    variant: ArcadeButtonVariant.dark,
                    onPressed: () => context.push('/settings'),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.25),
                  child: ArcadeButton(
                    label: 'Quitter',
                    fontSize: 16,
                    small: true,
                    variant: ArcadeButtonVariant.dark,
                    onPressed: () {
                      HapticFeedback.lightImpact().ignore();
                      SystemNavigator.pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
