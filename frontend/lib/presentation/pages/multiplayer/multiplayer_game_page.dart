import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/icons/wordstorm_icons.dart';
import '../../../core/widgets/letter_tile.dart';
import '../../../core/widgets/response_row.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../controllers/multiplayer_controller.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final _multi = Get.find<MultiplayerController>();
  final Map<String, TextEditingController> _answers = {};
  Timer? _clock;
  Timer? _saveDebounce;
  int _remaining = 0;
  bool _submitted = false;
  bool get _noTimer => _multi.session.value?.setup.durationSeconds == 0;
  bool get _allFilled =>
      (_multi.session.value?.setup.categories ?? const <String>[]).every(
        (category) => _answers[category]?.text.trim().isNotEmpty ?? false,
      );

  @override
  void initState() {
    super.initState();
    final endsAt = DateTime.tryParse('${_multi.round['ends_at'] ?? ''}')
        ?.toLocal();
    if (endsAt != null) {
      _updateRemaining(endsAt);
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining(endsAt);
        if (_remaining == 0 && !_submitted) _finish();
      });
    }
  }

  void _updateRemaining(DateTime endsAt) {
    if (!mounted) return;
    setState(
      () => _remaining = endsAt
          .difference(DateTime.now())
          .inSeconds
          .clamp(0, 99999),
    );
  }

  Future<void> _finish() async {
    if (_submitted) return;
    _submitted = true;
    _clock?.cancel();
    _saveDebounce?.cancel();
    await _multi.finishRound({
      for (final entry in _answers.entries) entry.key: entry.value.text,
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _saveDebounce?.cancel();
    for (final controller in _answers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final session = _multi.session.value;
    final categories = session?.setup.categories ?? const <String>[];
    final letter = '${_multi.round['letter'] ?? ''}';
    final number = _multi.round['number'] ?? 1;
    return ScreenScaffold(
      showSunburst: true,
      skylineHeight: 240,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$_remaining',
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  fontSize: 25,
                  color: AppColors.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MANCHE $number / ${session?.setup.rounds ?? 1}',
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 22,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LetterTile(letter: letter, size: 86),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ResponseRow(
                      category: category,
                      iconName: categoryIconName(category),
                      controller: _answers.putIfAbsent(
                        category,
                        TextEditingController.new,
                      ),
                      onChanged: (_) {
                        setState(() {});
                        _saveDebounce?.cancel();
                        _saveDebounce = Timer(
                          const Duration(milliseconds: 350),
                          () {
                            _multi.submitAnswers({
                              for (final entry in _answers.entries)
                                entry.key: entry.value.text,
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_multi.error.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                _multi.error.value!,
                style: const TextStyle(color: AppColors.coral),
              ),
            ),
          ArcadeButton(
            label: _multi.busy.value
                ? 'Envoi…'
                : (_noTimer ? 'STOP' : 'Valider'),
            variant: ArcadeButtonVariant.green,
            onPressed: _multi.busy.value || (_noTimer && !_allFilled)
                ? null
                : _finish,
          ),
        ],
      ),
    );
  });
}
