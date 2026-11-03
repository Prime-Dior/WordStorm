import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cadre simple partagé par les pages : fond uni, zone sûre et marge.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.child,
    super.key,
    this.day = false,
    this.skylineHeight = 0,
    this.showSunburst = false,
    this.burstTop = 0,
    this.padding = const EdgeInsets.all(16),
  });

  // Ces options sont gardées pour ne pas modifier les appels des pages.
  final bool day;
  final double skylineHeight;
  final bool showSunburst;
  final double burstTop;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgTop, AppColors.navyBlue, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
