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
        color: const Color(0xEE17223A),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            children: [
              const Text(
                'RÈGLES',
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 29,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RuleText(
                        'Manche : une lettre tirée, un mot par catégorie qui commence par cette lettre.',
                      ),
                      _RuleText(
                        'Barème : 15 pt si ta réponse valide est la seule.',
                      ),
                      _RuleText(
                        '5 catégories obligatoires (cadenas) : Prénom, Ville, Pays, Animal, Objet.',
                      ),
                      _RuleText(
                        'Catégories : Aléatoire (4 tirées au sort par lancement) ou Personnalisé. 12 catégories au total maximum.',
                      ),
                      _RuleText(
                        'En multijoueur : 10 pt pour une réponse valide unique, 5 pt si elle est partagée, 0 pt si elle est invalide.',
                      ),
                      _RuleText(
                        'Mots réutilisés et limites du dictionnaire : voir la configuration appliquée à la partie.',
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
  const _RuleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.offWhite,
      ),
    ),
  );
}
