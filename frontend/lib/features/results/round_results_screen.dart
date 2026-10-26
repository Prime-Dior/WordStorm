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
import '../../core/widgets/ui_kit.dart';
import '../../domain/scoring.dart';
import '../multiplayer/demo_room.dart';
import '../skeleton/status_screen.dart';

/// Résultats de manche (maquette 12) : carte du score de la manche et
/// du total, puis une ligne par catégorie (réponse, règle appliquée,
/// points). Boutons : MANCHE SUIVANTE (ou SCORE FINAL) et MENU.
///
/// Les conflits de règles portent le badge « Règle à trancher ».
class RoundResultsScreen extends ConsumerWidget {
  const RoundResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soloSessionProvider);
    if (state.roundHistory.isEmpty) {
      // Page rechargée sans manche jouée : retour au menu.
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
    final lines = [
      for (final category in setup.categories)
        result.score.lineFor('solo', category),
    ];
    final roundTotal = lines.fold(0, (sum, line) => sum + line.points);
    final grandTotal = state.roundHistory.fold(
      0,
      (sum, r) => sum + r.score.totalFor('solo'),
    );
    final multi = ref.watch(multiplayerGameProvider);

    void next() {
      if (isLast) {
        context.pushReplacement(multi ? '/podium' : '/final');
      } else {
        ref.read(soloSessionProvider.notifier).nextRound();
        context.pushReplacement('/wheel');
      }
    }

    return ScreenScaffold(
      skylineHeight: 0,
      showSunburst: true,
      burstTop: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          ScreenTitle('Manche ${result.round} / ${setup.rounds}'),
          const SizedBox(height: 10),
          _ScoreCard(
            letter: result.letter,
            roundScore: roundTotal,
            grandTotal: grandTotal,
          ),
          const SizedBox(height: 12),
          const Text(
            'Score personnel · réponses de cette manche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              color: AppColors.blueGray,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: lines.length,
              itemBuilder: (context, i) {
                final category = setup.categories[i];
                return _CategoryResultRow(
                  category: category,
                  answer: (state.answeredByCategory[category] ?? '').trim(),
                  line: lines[i],
                );
              },
            ),
          ),
          if (lines.any((l) => l.conflict)) ...[
            const _RuleSignBadge(),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              ArcadeButton(
                label: isLast ? 'Score final' : 'Manche suivante',
                fontSize: 24,
                flex: 2,
                onPressed: next,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ArcadeButton(
                  label: 'Menu',
                  variant: ArcadeButtonVariant.dark,
                  fontSize: 24,
                  onPressed: () => context.go('/menu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte « Score de la manche · lettre R » : héros, score, total.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.letter,
    required this.roundScore,
    required this.grandTotal,
  });

  final String letter;
  final int roundScore;
  final int grandTotal;

  @override
  Widget build(BuildContext context) => DarkPanel(
    padding: const EdgeInsets.fromLTRB(10, 8, 16, 10),
    child: Row(
      children: [
        const HeroImage(width: 92),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score de la manche · lettre $letter',
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  color: AppColors.blueGray,
                ),
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: roundScore),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  '$value',
                  style: const TextStyle(
                    fontFamily: AppTheme.monoFont,
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              Text(
                'Total : $grandTotal pt',
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  color: AppColors.blueGray,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Ligne de résultat : pastille, catégorie, « réponse · règle », points.
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
    final empty = answer.isEmpty;
    final points = line.points;
    final detail = empty ? '— · Pas de réponse' : '$answer · ${line.reason}';
    final pointsColor = switch (line.tier) {
      ScoreTier.invalid => AppColors.blueGray,
      _ => AppColors.yellow,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kPanelColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CategoryBadge(
            iconName: categoryIconName(category),
            color: categoryColor(category),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.offWhite,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 11,
                    color: AppColors.blueGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            points > 0 ? '$points pt' : '–',
            style: TextStyle(
              fontFamily: AppTheme.monoFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: points > 0 ? pointsColor : AppColors.blueGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge « Règle à trancher » (conflit réutilisation / bonus, question Q1).
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
