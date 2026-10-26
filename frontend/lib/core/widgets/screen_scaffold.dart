import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'decor.dart';

/// Socle visuel commun des écrans (maquette `.s`) : fond dégradé nuit
/// (ou ciel de jour pour l'accueil), décor d'immeubles, zones de sécurité,
/// coins arrondis gérés par l'app.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.child,
    super.key,
    this.day = false,
    this.skylineHeight = 420,
    this.showSunburst = false,
    this.burstTop = 0.38,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 18),
    this.alertFrame = false,
  });

  /// Cadre corail autour de l'écran (alerte des 10 dernières secondes).
  final bool alertFrame;

  /// Jour : accueil only (`.sky` avec `data-d="1"`).
  final bool day;
  final double skylineHeight;
  final bool showSunburst;
  final double burstTop;

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgBottom,
      child: Stack(
        children: [
          // Ciel (dégradé du haut).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: day
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF58C4FF),
                          Color(0xFF9FD9FC),
                          Color(0xFFFFD9A0),
                        ],
                        stops: [0, 0.45, 0.72],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.bgTop, AppColors.bgBottom],
                        stops: [0, 0.7],
                      ),
              ),
            ),
          ),

          // Tons radiaux de nuit (`.s.nt .sky`).
          if (!day)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.4, -0.7),
                    radius: 0.45,
                    colors: [Color(0x552EC4B6), Colors.transparent],
                  ),
                ),
              ),
            ),

          if (showSunburst)
            Positioned(
              top: MediaQuery.sizeOf(context).height * burstTop - 280,
              left: (MediaQuery.sizeOf(context).width - 560) / 2,
              child: const IgnorePointer(child: Sunburst()),
            ),

          // Décor d'immeubles en bas (absent si la hauteur vaut 0).
          if (skylineHeight > 0)
            Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: CitySkyline(day: day, height: skylineHeight),
            ),
          ),

          // Cadre d'alerte (maquette 11) : bordure corail lumineuse.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: alertFrame ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.coral, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withAlpha(0x66),
                        blurRadius: 24,
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu. La Material (translucide) est requise par les
          // TextField/Switch des écrans ; le décor est dessiné en dessous.
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: SafeArea(
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
