import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/arcade_button.dart';
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
          const Positioned(left: 18, top: 56, child: WordstormLogo()),
          // Slogan « Des mots, un seul champion ! ».
          Positioned(
            left: 18,
            top: 170,
            child: Text(
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
            bottom: 190,
            child: Image.asset(
              'assets/images/personnage_w.png',
              width: size.width * 0.62,
              fit: BoxFit.contain,
            ),
          ),
          // Quelques lettres pour rappeler le principe du jeu.
          Positioned(
            left: 18,
            bottom: 230,
            child: Transform.rotate(
              angle: -0.42,
              child: _HomeTile(
                letter: 'R',
                colorTop: Color(0xFFFF9A9D),
                colorBottom: Color(0xFFFF5A5F),
                shadow: Color(0xFFB93A3E),
              ),
            ),
          ),
          const Positioned(
            left: 88,
            bottom: 170,
            child: Transform.rotate(angle: 0.31, child: _HomeTile(letter: 'E')),
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

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.letter,
    this.colorTop = const Color(0xFFFFE27A),
    this.colorBottom = const Color(0xFFFFB703),
    this.shadow = const Color(0xFFC98300),
  });

  final String letter;
  final Color colorTop;
  final Color colorBottom;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    final s = letter == 'R' ? 46.0 : 42.0;
    final font = letter == 'R' ? 30.0 : 27.0;
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorTop, colorBottom],
        ),
        boxShadow: [
          BoxShadow(color: shadow, offset: const Offset(0, 5)),
          const BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 10),
            blurRadius: 12,
          ),
          const BoxShadow(color: Color(0xAAFFFFFF), offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Bangers',
          fontSize: font,
          color: letter == 'R' ? Colors.white : const Color(0xFF3A2A00),
          shadows: letter == 'R'
              ? null
              : const [Shadow(color: Color(0x99FFFFFF), offset: Offset(0, 2))],
        ),
      ),
    );
  }
}
