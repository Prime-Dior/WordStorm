import 'package:flutter/material.dart';

/// Titre texte WordStorm, en version grande ou compacte.
class WordstormLogo extends StatelessWidget {
  const WordstormLogo({
    this.fontSize = 48,
    super.key,
    this.rotationDegrees = 0,
    this.showLightning = false,
  });

  final double fontSize;
  final double rotationDegrees;
  final bool showLightning;

  @override
  Widget build(BuildContext context) {
    return Text(
      'WORDSTORM',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFB703),
      ),
    );
  }
}

/// Titre compact utilisé dans les pages internes.
class WordstormLogoSmall extends StatelessWidget {
  const WordstormLogoSmall({
    this.fontSize = 28,
    super.key,
    this.showLightning = false,
  });

  final double fontSize;
  final bool showLightning;

  @override
  Widget build(BuildContext context) {
    return WordstormLogo(fontSize: fontSize, showLightning: showLightning);
  }
}
