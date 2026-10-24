import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/letter_tile.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../domain/scoring.dart';
import '../skeleton/status_screen.dart';

/// Résultats de manche (Figma 12) : pour chaque catégorie, la réponse
/// saisie, les points et la règle appliquée en français. En solo le
/// palier 10 (réponse unique) ne s'y applique pas — toute réponse valide
/// vaut le bonus du plus haut palier. Les conflits de règles portent le
/// badge « Règle à trancher » (question Q1).
class RoundResultsScreen extends ConsumerWidget {
  const RoundResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soloSessionProvider);
    if (state.roundHistory.isEmpty) {
      // Rechargé froid (aucune manche complétée) : retour menu.
      return const StatusScreen(
        title: 'Aucune manche',
        message:
            'Aucune manche terminée dans cette session. Rejoue depuis le menu.',
        actionLabel: 'Menu',
        actionRoute: '/menu',
      );
    }

    final result = state.roundHistory.last;
    final setup = state.setupOrDefault;
    final isLast = result.round >= setup.rounds;

    final totalRows = [
      for (final category in setup.categories)
        result.score.lineFor('solo', category),
    ];
    final total = totalRows.fold(0, (modified, line) => modified + line.points);

    return ScreenScaffold(
      skylineHeight: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LetterTile(letter: result.letter, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MANCHE ${result.round} — FIN',
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 26,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontFamily: AppTheme.monoFont,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellow,
                    ),
                  ),
                  const Text(
                    'POINTS',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.blueGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: totalRows.length,
              itemBuilder: (context, i) {
                final category = setup.categories[i];
                final line = totalRows[i];
                return _CategoryResultRow(
                  category: category,
                  answer: state.answeredByCategory[category] ?? '',
                  line: line,
                );
              },
            ),
          ),
          // Badge « règle à trancher » (conflits de règles, question Q1).
          if (totalRows.any((l) => l.conflict)) const _RuleSignBadge(),
          const SizedBox(height: 12),
          ArcadeButton(
            label: isLast ? 'Terminer' : 'Manche suivante',
            onPressed: () {
              if (isLast) {
                context.pushReplacement('/final');
              } else {
                ref.read(soloSessionProvider.notifier).nextRound();
                context.pushReplacement('/wheel');
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Ligne de résultat d'une catégorie (réponse + points + justification).
class _CategoryResultRow extends StatelessWidget {
  const _CategoryResultRow({
    required this.category,
    required this.answer,
    required this.line,
  });

  final String category;
  final String answer;
  final ScoreLine line;

  @override
  Widget build(BuildContext context) {
    final empty = answer.trim().isEmpty;
    final points = line.points;
    final color = switch (line.tier) {
      ScoreTier.onlyValid => AppColors.validate,
      ScoreTier.uniqueValid => AppColors.teal,
      ScoreTier.shared || ScoreTier.reused => AppColors.yellow,
      ScoreTier.invalid => AppColors.coral,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xAA0A1330),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22FFFFFF), width: 2),
      ),
      child: Row(
        children: [
          CategoryBadge(iconName: categoryIconName(category)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueGray,
                  ),
                ),
                Text(
                  empty ? 'Pas de réponse' : answer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.offWhite,
                  ),
                ),
                Text(
                  line.reason,
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: empty ? AppColors.blueGray : color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$points',
            style: TextStyle(
              fontFamily: AppTheme.monoFont,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: points > 0 ? color : AppColors.blueGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge « Règle à trancher » (résultats, quand un conflit de règles a
/// été arbitré : question Q1, devise du prompt « pas de silence »).
class _RuleSignBadge extends StatelessWidget {
  const _RuleSignBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.yellow.withAlpha(0x22),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.yellow, width: 2),
    ),
    child: Row(
      children: [
        WordstormIcons.warn(size: 18, color: AppColors.yellow),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Règle à trancher : mot réutilisé — 5 points '
            '(conflit avec le bonus, décision provisoire).',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.yellow,
            ),
          ),
        ),
      ],
    ),
  );
}
