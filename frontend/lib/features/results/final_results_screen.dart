import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/audio/sound_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';

/// Score final en solo (maquette 07) : carte « Ton score » avec le total,
/// détail de chaque manche (lettre et points), rappel « pas de
/// classement en solo », boutons REJOUER et MENU.
class FinalResultsScreen extends ConsumerStatefulWidget {
  const FinalResultsScreen({super.key});

  @override
  ConsumerState<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends ConsumerState<FinalResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Fanfare + vibration, une fois à l'arrivée sur l'écran.
    unawaited(ref.read(soundEngineProvider).play(SoundCue.victory));
    unawaited(ref.read(vibrationProvider).heavy());
  }

  Future<void> _replay() async {
    // Même configuration, mots consommés et manches remis à zéro.
    await ref.read(soloSessionProvider.notifier).restart();
    if (mounted) context.pushReplacement('/wheel');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soloSessionProvider);
    final rounds = state.roundHistory;
    final total = rounds.fold(0, (sum, r) => sum + r.score.totalFor('solo'));

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.1,
      skylineHeight: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const ScreenTitle('Score final'),
          const SizedBox(height: 10),
          DarkPanel(
            padding: const EdgeInsets.fromLTRB(10, 8, 16, 10),
            child: Row(
              children: [
                const HeroImage(width: 92),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ton score',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 13,
                          color: AppColors.blueGray,
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: total),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (context, value, _) => Text(
                          '$value',
                          style: const TextStyle(
                            fontFamily: AppTheme.monoFont,
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color: AppColors.yellow,
                          ),
                        ),
                      ),
                      Text(
                        '${rounds.length} manche${rounds.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 12,
                          color: AppColors.blueGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final r in rounds)
                  _RoundSummaryRow(
                    round: r.round,
                    letter: r.letter,
                    points: r.score.totalFor('solo'),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Mode solo : score personnel uniquement, pas de classement.',
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
          Row(
            children: [
              ArcadeButton(
                label: 'Rejouer',
                flex: 2,
                onPressed: _replay,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ArcadeButton(
                  label: 'Menu',
                  variant: ArcadeButtonVariant.dark,
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

/// Ligne du récapitulatif : pastille de lettre, « Manche n », points.
class _RoundSummaryRow extends StatelessWidget {
  const _RoundSummaryRow({
    required this.round,
    required this.letter,
    required this.points,
  });

  final int round;
  final String letter;
  final int points;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: kPanelColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        LetterBadge(letter),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manche $round',
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.offWhite,
                ),
              ),
              Text(
                'Lettre $letter',
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  color: AppColors.blueGray,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$points',
          style: const TextStyle(
            fontFamily: AppTheme.monoFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.yellow,
          ),
        ),
      ],
    ),
  );
}
