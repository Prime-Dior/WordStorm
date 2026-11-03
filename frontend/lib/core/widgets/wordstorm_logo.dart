import 'package:flutter/material.dart';

/// Affiche le logo WordStorm préparé comme image.
class WordstormLogo extends StatelessWidget {
  const WordstormLogo({super.key, this.width = 250});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/wordstorm_logo.png',
      width: width,
      fit: BoxFit.contain,
      semanticLabel: 'Wordstorm',
    );
  }
}
