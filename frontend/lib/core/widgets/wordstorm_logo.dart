import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Logo « WORDSTORM » : Bangers, deux lignes (« WORD » dégradé jaune,
/// « STORM » dégradé bleu), contour épais bleu-nuit + ombre portée sombre,
/// rotation légère (maquette `.lg`/`.l`, `-webkit-text-stroke .17em`).
///
/// L'animation de chute décalée des lettres (70 ms d'intervalle, `.6s`)
/// est ajoutée à la phase 8 — cf. `docs/RESTE_A_FAIRE.md`.
class WordstormLogo extends StatelessWidget {
  const WordstormLogo({
    this.fontSize = 84,
    super.key,
    this.rotationDegrees = -5,
  });

  final double fontSize;

  /// Rotation de l'ensemble (accueil : −5°, menus : −3°).
  final double rotationDegrees;

  static const List<Color> yellowGradient = [
    Color(0xFFFFF08A),
    AppColors.yellow,
    Color(0xFFE07F00),
  ];
  static const List<Color> blueGradient = [
    Color(0xFFA8ECFF),
    Color(0xFF2FB6FF),
    Color(0xFF1066D0),
  ];

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * math.pi / 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OutlinedText(
            text: 'WORD',
            fontSize: fontSize,
            gradient: yellowGradient,
          ),
          Padding(
            padding: EdgeInsets.only(left: fontSize * 0.1),
            child: _OutlinedText(
              text: 'STORM',
              fontSize: fontSize,
              gradient: blueGradient,
            ),
          ),
        ],
      ),
    );
  }
}

/// Texte Bangers en dégradé, contour épais bleu nuit et ombre portée dure.
class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.fontSize,
    required this.gradient,
  });

  final String text;
  final double fontSize;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    TextStyle base({bool solid = false, Color? color, Paint? foreground}) =>
        TextStyle(
          fontFamily: AppTheme.displayFont,
          fontSize: fontSize,
          height: 0.9,
          color: solid ? color : null,
          foreground: foreground,
        );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = fontSize * 0.17
      ..color = AppColors.navyBlue
      ..strokeJoin = StrokeJoin.round;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ombre portée dure (`text-shadow: 0 .09em 0 #0B1222, 0 .15em .1em`).
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.09, left: fontSize * 0.02),
          child: Text(
            text,
            softWrap: false,
            style: base(solid: true, color: const Color(0xFF0B1222)),
          ),
        ),
        // Contour épais bleu-nuit.
        Text(text, softWrap: false, style: base(foreground: stroke)),
        // Lettre en dégradé (couleur transparente + ShaderMask).
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
            stops: const [0, 0.52, 1],
          ).createShader(bounds),
          child: Text(
            text,
            softWrap: false,
            style: base(solid: true, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Variante compacte des en-têtes (menu, écrans internes).
class WordstormLogoSmall extends StatelessWidget {
  const WordstormLogoSmall({this.fontSize = 46, super.key});

  final double fontSize;

  @override
  Widget build(BuildContext context) =>
      WordstormLogo(fontSize: fontSize, rotationDegrees: -3);
}
