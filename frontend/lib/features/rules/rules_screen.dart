import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_scaffold.dart';

/// Règles du jeu (Figma 19) : résumé honnête des règles effectivement
/// appliquées par le moteur (barème, réutilisation provisoire, lettres,
/// manches). Les points « à trancher » sont affichés comme tels.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'RÈGLES DU JEU',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 30,
              color: AppColors.offWhite,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: const [
                _Card(
                  title: 'Principe',
                  body:
                      'À chaque manche, une lettre est tirée au sort. '
                      'Tu réponds aux catégories le plus vite possible : '
                      'chaque ligne doit commencer par la lettre tirée.',
                ),
                _Card(
                  title: 'Catégories',
                  body:
                      '5 obligatoires (Prénom, Ville, Pays, Animal, Objet) '
                      '— cadenassées. Maximum 12 catégories par partie. '
                      'Mode Aléatoire : socle de 5 + 4 tirées au sort.',
                ),
                _Card(
                  title: 'Barème',
                  body:
                      '15 pts : seule réponse valide (bonus).\n'
                      '10 pts : réponse unique (multijoueur).\n'
                      '5 pts : réponse identique à celle d\'un autre joueur.\n'
                      '0 pt : vide, trop courte, mauvaise lettre ou '
                      'absente du dictionnaire.',
                ),
                _Card(
                  title: 'Mot déjà utilisé',
                  body:
                      'Un mot déjà joué dans une autre manche, la même '
                      'catégorie, rapporte 5 points au lieu d\'être '
                      'refusé. Le même mot reste autorisé dans une autre '
                      'catégorie. (Règle à trancher — décision '
                      'provisoire.)',
                ),
                _Card(
                  title: 'Lettres',
                  body:
                      'Tirage : A–Z sans K W X Y Z (Q inclus). '
                      'Option « lettres difficiles » pour les inclure.',
                ),
                _Card(
                  title: 'Manches et durées',
                  body:
                      '1 à 5 manches. Durées : 20 s (Speed), 30, 45, '
                      '60, 90, 120 s ou sans chrono — STOP termine la '
                      'manche pour tous.',
                ),
                _Card(
                  title: 'Prénoms',
                  body:
                      'Le Prénom suit une règle souple : 3 lettres '
                      'minimum, sans consultation du dictionnaire.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 20,
            color: AppColors.yellow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: AppColors.offWhite,
          ),
        ),
      ],
    ),
  );
}
