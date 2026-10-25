import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Écrans d'état (Figma 14–17) : ATTENTE · CHARGEMENT · ERREUR ·
/// SALON INTROUVABLE. Réutilisables avec un message honnête — un état
/// « simulé » est interdit par le prompt ; ces écrans nomment ce qui
/// manque (ex. salons en ligne livrés à la phase 7).
class StatusScreen extends StatelessWidget {
  const StatusScreen({
    required this.title,
    required this.message,
    super.key,
    this.kind = StatusKind.info,
    this.actionLabel,
    this.actionRoute,
  });

  final String title;
  final String message;
  final StatusKind kind;
  final String? actionLabel;
  final String? actionRoute;

  static const Map<StatusKind, Color> _colors = {
    StatusKind.info: AppColors.yellow,
    StatusKind.waiting: AppColors.teal,
    StatusKind.error: AppColors.coral,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[kind] ?? AppColors.yellow;
    return ScreenScaffold(
      skylineHeight: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WordstormLogoSmall(),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 34,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: AppColors.offWhite,
                ),
              ),
            ),
            const SizedBox(height: 26),
            if (actionLabel != null && actionRoute != null)
              ArcadeButton(
                label: actionLabel!,
                small: true,
                onPressed: () => context.push(actionRoute!),
              ),
          ],
        ),
      ),
    );
  }
}

enum StatusKind { info, waiting, error }
