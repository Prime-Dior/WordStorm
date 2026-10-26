import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';

/// Résumé des règles appliquées par le moteur, dans la fenêtre 19.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RÈGLES',
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 32,
                  color: AppColors.offWhite,
                  shadows: [
                    Shadow(color: Color(0xFF0C1429), offset: Offset(0, 3)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RuleText(
                        'Manche : une lettre tirée, un mot par catégorie qui '
                        'commence par cette lettre.',
                      ),
                      _RuleText('Barème : 15 pt', bold: true),
                      _RuleText(
                        '5 catégories obligatoires (cadenas) : Prénom, Ville, '
                        'Pays, Animal, Objet.',
                      ),
                      _RuleText(
                        'Catégories : Aléatoire (4 tirées au sort au '
                        'lancement) ou Personnalisé.\n12 catégories au total '
                        'maximum.',
                      ),
                      _RuleText(
                        'En multijoueur : 15 pt si tu es le seul à trouver, '
                        '10 pt pour une réponse valide unique, 5 pt si '
                        'elle est partagée, 0 pt si elle est invalide.',
                      ),
                    ],
                  ),
                ),
              ),
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
    ),
  );
}

class _RuleText extends StatelessWidget {
  const _RuleText(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 12,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        height: 1.35,
        color: AppColors.offWhite,
      ),
    ),
  );
}
