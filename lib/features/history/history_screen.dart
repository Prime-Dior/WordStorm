import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Classement (bouton du menu) — affiché comme **historique personnel /
/// meilleurs scores personnels** (décision ANALYSE §5-10 : pas de
/// classement global sans serveur). L'enregistrement des scores via
/// `HistoryRepository` est à la phase 6 ; en attendant, cet écran
/// l'annonce honnêtement — rien n'est simulé.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => ScreenScaffold(
    skylineHeight: 240,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WordstormLogoSmall(),
          const SizedBox(height: 26),
          const Text(
            'TON HISTORIQUE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 32,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tes scores et tes meilleures performances '
              'apparaîtront ici dès la phase 6 '
              '(enregistrement local des parties).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: AppColors.offWhite,
              ),
            ),
          ),
          const SizedBox(height: 26),
          ArcadeButton(
            label: 'Menu',
            small: true,
            onPressed: () => context.push('/menu'),
          ),
        ],
      ),
    ),
  );
}
