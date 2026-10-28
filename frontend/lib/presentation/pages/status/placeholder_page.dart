import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/screen_scaffold.dart';

/// Écran de démonstration du routage, phase 1 : chaque écran réel est
/// implémenté à la phase 4 (voir `docs/PLAN.md`).
///
/// Le contenu est volontairement minimal et clairement marqué : les
/// visuels exacts sont dans la maquette, la phase 4 les reproduit.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, this.route, super.key});

  final String title;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 36,
                color: AppColors.offWhite,
              ),
            ),
            const Text(
              'Implémentation à la phase 4 (voir docs/PLAN.md).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.offWhite,
              ),
            ),
            if (route != null)
              Text(
                route!,
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  fontSize: 12,
                  color: AppColors.blueGray,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
