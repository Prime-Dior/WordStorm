import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/letter_tile.dart';
import '../../../core/widgets/response_row.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../domain/models/round_model.dart';
import '../../controllers/multiplayer_game_controller.dart';

class MultiplayerGameScreen extends GetView<MultiplayerGameController> {
  const MultiplayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentRound = controller.round.value;
      final finished = currentRound.status == 'completed';
      final categories = controller.session.categories;
      final total = categories.length;
      final filled = controller.answers.values
          .where((answer) => answer.text.trim().isNotEmpty)
          .length;
      final hasTimer = controller.session.durationSeconds > 0;
      final timerColor = controller.secondsRemaining.value <= 10 && hasTimer
          ? AppColors.coral
          : AppColors.yellow;

      return ScreenScaffold(
        showSunburst: true,
        burstTop: 0.1,
        skylineHeight: 240,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: hasTimer
                                  ? controller.secondsRemaining.value /
                                        controller.session.durationSeconds
                                  : 1,
                              strokeWidth: 9,
                              backgroundColor: const Color(0xFF0B1330),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                timerColor,
                              ),
                            ),
                          ),
                          Text(
                            hasTimer
                                ? '${controller.secondsRemaining.value}'
                                : '∞',
                            style: TextStyle(
                              fontFamily: AppTheme.monoFont,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: timerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MANCHE ${currentRound.number} / ${controller.session.roundCount}',
                            style: const TextStyle(
                              fontFamily: AppTheme.displayFont,
                              fontSize: 22,
                              color: AppColors.offWhite,
                            ),
                          ),
                          Text(
                            'SALON ${controller.session.roomCode}',
                            style: const TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.offWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '$filled / $total réponses',
                      style: const TextStyle(
                        fontFamily: AppTheme.monoFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.offWhite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : filled / total,
                          minHeight: 8,
                          backgroundColor: const Color(0x66000000),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: LetterTile(
                    letter: currentRound.letter ?? '…',
                    size: 100,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: finished
                      ? SingleChildScrollView(
                          child: _RoundResults(answers: currentRound.answers),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ResponseRow(
                                key: ValueKey(category),
                                category: category,
                                controller: controller.answers[category],
                                enabled: controller.canEdit,
                                onChanged: controller.answerChanged,
                              ),
                            );
                          },
                        ),
                ),
                if (controller.error.value != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      controller.error.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.coral),
                    ),
                  ),
                if (finished)
                  _resultAction(controller)
                else
                  Obx(() {
                    controller.formRevision.value;
                    final canStop =
                        controller.session.durationSeconds > 0 ||
                        controller.allCategoriesFilled;

                    return ArcadeButton(
                      label:
                          controller.isSaving.value ||
                              controller.isLocking.value
                          ? 'Envoi…'
                          : controller.session.durationSeconds == 0
                          ? 'STOP · terminer la manche'
                          : 'Enregistrer mes réponses',
                      variant: ArcadeButtonVariant.teal,
                      onPressed: controller.canEdit && canStop
                          ? controller.submitAnswers
                          : null,
                    );
                  }),
                const SizedBox(height: 8),
                ArcadeButton(
                  label: 'Quitter la partie',
                  variant: ArcadeButtonVariant.dark,
                  small: true,
                  onPressed: controller.returnToMenu,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _resultAction(MultiplayerGameController game) {
    if (game.isGameFinished.value) {
      return ArcadeButton(
        label: game.isSaving.value ? 'Chargement…' : 'Classement final',
        variant: ArcadeButtonVariant.teal,
        onPressed: game.isSaving.value ? null : game.openFinalResults,
      );
    }

    if (game.session.isHost) {
      return ArcadeButton(
        label: game.isSaving.value ? 'Démarrage…' : 'Manche suivante',
        variant: ArcadeButtonVariant.teal,
        onPressed: game.isSaving.value ? null : game.startNextRound,
      );
    }

    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'En attente du démarrage de la prochaine manche par l’hôte…',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.blueGray),
      ),
    );
  }
}

class _RoundResults extends StatelessWidget {
  const _RoundResults({required this.answers});

  final List<RoundAnswerModel> answers;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Aucun résultat reçu pour cette manche.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.blueGray),
        ),
      );
    }

    final grouped = <String, List<RoundAnswerModel>>{};
    for (final answer in answers) {
      grouped.putIfAbsent(answer.category, () => []).add(answer);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in grouped.entries)
          Card(
            color: const Color(0xFF14213D),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      color: AppColors.yellow,
                      fontSize: 17,
                    ),
                  ),
                  for (final answer in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${answer.nickname ?? 'Joueur'} : ${answer.value ?? '—'} · '
                        '${answer.points ?? 0} pts${_validationLabel(answer)}',
                        style: const TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          color: AppColors.offWhite,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _validationLabel(RoundAnswerModel answer) {
    switch (answer.validationStatus) {
      case 'unverified':
        final reason = switch (answer.scoreReason) {
          'dictionary_unavailable' => 'dictionnaire indisponible',
          'no_french_definition' => 'pas de définition française',
          _ => 'à vérifier',
        };
        return ' · non vérifié ($reason)';
      case 'invalid':
        return ' · refusé';
      case 'valid':
        final source = switch (answer.dictionarySource) {
          'local' => 'dictionnaire local',
          'wiktionary' => 'Wiktionnaire',
          'gemini' => 'Gemini',
          _ => null,
        };
        return source == null ? ' · validé' : ' · validé par $source';
      case 'blank':
        return ' · vide';
      default:
        return '';
    }
  }
}
