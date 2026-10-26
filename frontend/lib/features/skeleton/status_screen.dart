import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';

/// États de la maquette 14 à 17, présentés comme des fenêtres au-dessus
/// de l'écran courant.
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
    final color = _colors[kind]!;
    final isBusy = kind == StatusKind.waiting;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBusy)
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation(AppColors.blueGray),
                    backgroundColor: AppColors.yellow,
                  ),
                )
              else
                WordstormIcons.warn(size: 58, color: color),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 27,
                  height: 1,
                  color: color,
                ),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.blueGray,
                  ),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ArcadeButton(
                    label: actionLabel!,
                    variant: ArcadeButtonVariant.red,
                    small: true,
                    onPressed: actionRoute == null
                        ? () => context.pop()
                        : () => context.push(actionRoute!),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ArcadeButton(
                label: 'Fermer',
                variant: ArcadeButtonVariant.dark,
                small: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum StatusKind { info, waiting, error }

/// Démos rapides des pages d'état dans les paramètres.
class StatusDemoButtons extends StatelessWidget {
  const StatusDemoButtons({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 8,
    runSpacing: 8,
    children: [
      _demo(context, 'Attente', '/waiting', ArcadeButtonVariant.dark),
      _demo(context, 'Chargement', '/loading', ArcadeButtonVariant.dark),
      _demo(context, 'Erreur', '/connection-error', ArcadeButtonVariant.red),
    ],
  );

  Widget _demo(
    BuildContext context,
    String label,
    String route,
    ArcadeButtonVariant variant,
  ) => ArcadeButton(
    label: label,
    variant: variant,
    small: true,
    onPressed: () => context.push(route),
  );
}
