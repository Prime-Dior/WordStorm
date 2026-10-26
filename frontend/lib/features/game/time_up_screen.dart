import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';

/// Écran « Temps écoulé ! » (maquette 06) : affiché quand le chrono
/// atteint 0. Les réponses sont verrouillées (cadenas) et rappelées
/// une par une avant de passer aux résultats de la manche.
class TimeUpScreen extends ConsumerWidget {
  const TimeUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soloSessionProvider);
    final categories = state.setupOrDefault.categories;
    final answers = state.answeredByCategory;
    final filled = categories
        .where((c) => (answers[c] ?? '').trim().isNotEmpty)
        .length;
    final total = categories.length;

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.12,
      skylineHeight: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: HeroImage(width: 130)),
          const SizedBox(height: 6),
          const Text(
            'TEMPS ÉCOULÉ !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 40,
              color: AppColors.coral,
              shadows: [Shadow(color: Color(0xFF0C1429), offset: Offset(0, 3))],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$filled / $total réponses enregistrées',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.blueGray,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final category in categories)
                  _LockedAnswerRow(
                    category: category,
                    answer: (answers[category] ?? '').trim(),
                  ),
                const SizedBox(height: 10),
                GradientProgressBar(value: total == 0 ? 0 : filled / total),
                const SizedBox(height: 12),
                const Text(
                  'Réponses verrouillées · vérification à la fin de la manche…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 11,
                    color: AppColors.blueGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ArcadeButton(
            label: 'Voir les résultats',
            onPressed: () => context.pushReplacement('/results'),
          ),
        ],
      ),
    );
  }
}

/// Réponse verrouillée : cadenas, catégorie, réponse en jaune (ou « — »).
class _LockedAnswerRow extends StatelessWidget {
  const _LockedAnswerRow({required this.category, required this.answer});

  final String category;
  final String answer;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: kPanelColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        WordstormIcons.lock(size: 16, color: AppColors.blueGray),
        const SizedBox(width: 10),
        Text(
          category,
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 13,
            color: AppColors.offWhite,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            answer.isEmpty ? '—' : answer,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.yellow,
            ),
          ),
        ),
      ],
    ),
  );
}
