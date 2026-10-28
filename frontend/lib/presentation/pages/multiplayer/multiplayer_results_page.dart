import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/letter_tile.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../data/api/multiplayer_session.dart';
import '../../controllers/multiplayer_controller.dart';

class MultiplayerResultsScreen extends StatefulWidget {
  const MultiplayerResultsScreen({super.key});

  @override
  State<MultiplayerResultsScreen> createState() =>
      _MultiplayerResultsScreenState();
}

class _MultiplayerResultsScreenState extends State<MultiplayerResultsScreen> {
  final _multi = Get.find<MultiplayerController>();
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    _refresh = Timer.periodic(const Duration(seconds: 2), (_) async {
      final number = (_multi.round['number'] as num?)?.toInt();
      if (number != null && _multi.round['status'] != 'completed') {
        try {
          final current = _multi.session.value;
          if (current != null) {
            _multi.round.assignAll(
              await _multi.api.getRound(current.code, number),
            );
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final answers = _multi.round['answers'] as List? ?? const [];
    final completed = _multi.round['status'] == 'completed';
    final session = _multi.session.value;
    final number = (_multi.round['number'] as num?)?.toInt() ?? 1;
    return ScreenScaffold(
      skylineHeight: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LetterTile(letter: '${_multi.round['letter'] ?? ''}', size: 54),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'RÉSULTATS DE MANCHE',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 23,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!completed)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'En attente des autres joueurs…',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blueGray),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                for (final value in answers)
                  _AnswerCard(
                    answer: value as Map<String, dynamic>,
                    category: categoryFromApi('${(value as Map)['category']}'),
                    canReview:
                        session?.isHost == true &&
                        value['validation_status'] == 'unverified',
                    onReview: (valid) => _multi.review(
                      (value['id'] as num).toInt(),
                      valid: valid,
                    ),
                  ),
              ],
            ),
          ),
          if (session?.isHost == true && completed)
            ArcadeButton(
              label: number < session!.setup.rounds
                  ? 'Manche suivante'
                  : 'Terminer',
              variant: ArcadeButtonVariant.teal,
              onPressed: () => _multi.nextRound(),
            )
          else if (completed)
            ArcadeButton(
              label: number < (session?.setup.rounds ?? number)
                  ? 'Retour au salon'
                  : 'Terminer',
              variant: ArcadeButtonVariant.dark,
              onPressed: _multi.nextRound,
            ),
        ],
      ),
    );
  });
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.answer,
    required this.category,
    required this.canReview,
    required this.onReview,
  });

  final Map<String, dynamic> answer;
  final String category;
  final bool canReview;
  final ValueChanged<bool> onReview;

  @override
  Widget build(BuildContext context) {
    final status = '${answer['validation_status']}';
    final points = answer['points'] ?? '…';
    return Card(
      color: const Color(0xCC0A1330),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$category · ${answer['nickname'] ?? 'Toi'}',
                    style: const TextStyle(
                      color: AppColors.blueGray,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${answer['value'] ?? 'Pas de réponse'}',
                    style: const TextStyle(
                      color: AppColors.offWhite,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    status == 'unverified'
                        ? 'À vérifier · ${answer['score_reason'] ?? ''}'
                        : status,
                    style: TextStyle(
                      color: status == 'unverified'
                          ? AppColors.yellow
                          : AppColors.teal,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (canReview) ...[
              IconButton(
                tooltip: 'Accepter',
                onPressed: () => onReview(true),
                icon: const Icon(Icons.check, color: AppColors.teal),
              ),
              IconButton(
                tooltip: 'Refuser',
                onPressed: () => onReview(false),
                icon: const Icon(Icons.close, color: AppColors.coral),
              ),
            ] else
              Text(
                '$points',
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  color: AppColors.yellow,
                  fontSize: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
