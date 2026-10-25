import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'icons/wordstorm_icons.dart';

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
    this.showLightning = false,
  });

  final double fontSize;

  /// Rotation de l'ensemble (accueil : −5°, menus : −3°).
  final double rotationDegrees;
  final bool showLightning;

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
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
          if (showLightning)
            Positioned(
              left: fontSize * 1.34,
              top: fontSize * 1.25,
              child: Transform.rotate(
                angle: 0.18,
                child: WordstormIcons.bolt(
                  size: fontSize * 0.19,
                  color: AppColors.yellow,
                ),
              ),
            ),
          if (showLightning)
            Positioned(
              left: fontSize * 0.04,
              top: -fontSize * 0.16,
              child: CustomPaint(
                size: Size(fontSize * 0.25, fontSize * 0.21),
                painter: _CrownPainter(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.offWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final crown = Path()
      ..moveTo(size.width * 0.08, size.height * 0.2)
      ..lineTo(size.width * 0.18, size.height * 0.78)
      ..lineTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.82, size.height * 0.78)
      ..lineTo(size.width * 0.92, size.height * 0.2)
      ..lineTo(size.width * 0.82, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.88)
      ..close();
    canvas.drawPath(crown, line);
    canvas.drawLine(
      Offset(size.width * 0.21, size.height * 0.98),
      Offset(size.width * 0.79, size.height * 0.98),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => false;
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
  const WordstormLogoSmall({
    this.fontSize = 46,
    super.key,
    this.showLightning = false,
  });

  final double fontSize;
  final bool showLightning;

  @override
  Widget build(BuildContext context) => WordstormLogo(
    fontSize: fontSize,
    rotationDegrees: -3,
    showLightning: showLightning,
  );
}
