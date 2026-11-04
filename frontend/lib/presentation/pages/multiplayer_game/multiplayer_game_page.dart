import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
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

      return ScreenScaffold(
        skylineHeight: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SALON ${controller.session.roomCode}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 24,
                color: AppColors.offWhite,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'MANCHE ${currentRound.number} / ${controller.session.roundCount}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 20,
                color: AppColors.yellow,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              finished
                  ? controller.isGameFinished.value
                        ? 'PARTIE TERMINÉE'
                        : 'RÉSULTATS DE LA MANCHE'
                  : controller.session.durationSeconds == 0
                  ? 'LETTRE : ${currentRound.letter ?? '…'} · SANS CHRONO'
                  : 'LETTRE : ${currentRound.letter ?? '…'} · ${controller.secondsRemaining.value} s',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: finished
                    ? _RoundResults(answers: currentRound.answers)
                    : Column(
                        children: [
                          for (final category in controller.session.categories)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextField(
                                controller: controller.answers[category],
                                enabled: controller.canEdit,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: category,
                                  filled: true,
                                  fillColor: AppColors.offWhite,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: controller.answerChanged,
                              ),
                            ),
                        ],
                      ),
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
                    !controller.session.isHost ||
                    controller.allCategoriesFilled;

                return ArcadeButton(
                  label: controller.isSaving.value || controller.isLocking.value
                      ? 'Envoi…'
                      : controller.session.durationSeconds == 0 &&
                            controller.session.isHost
                      ? 'STOP · voir les résultats'
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
