import 'package:flutter/material.dart';

/// Décor de fond conservé pour les pages qui l'utilisent encore.
class CitySkyline extends StatelessWidget {
  const CitySkyline({this.day = false, this.height = 420, super.key});

  final bool day;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: double.infinity);
  }
}

/// Les rayons lumineux ne sont plus affichés dans le thème simplifié.
class Sunburst extends StatelessWidget {
  const Sunburst({
    super.key,
    this.size = 560,
    this.baseAlpha = 0x11,
    this.durationSecs = 60,
  });

  final double size;
  final int baseAlpha;
  final int durationSecs;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
