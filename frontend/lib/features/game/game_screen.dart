import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/audio/sound_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/letter_tile.dart';
import '../../core/widgets/response_row.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';
import 'state/solo_session.dart';

/// Écran de manche (maquettes 05 et 11).
///
/// En-tête : anneau de chrono, « MANCHE n / N · Temps restant », avatar.
/// Puis la progression « n / N réponses », la grande tuile de lettre et
/// une ligne de réponse par catégorie.
/// - Avec chrono : VALIDER à tout moment ; à 0 s, les réponses sont
///   verrouillées et l'écran « Temps écoulé » s'affiche. Pendant les
///   10 dernières secondes : cadre, anneau et lignes passent au corail.
/// - Sans chrono : bouton STOP, grisé tant que tout n'est pas rempli.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Timer? _timer;
  int _remaining = 0;
  bool _ended = false;

  SoloSessionState get _state => ref.read(soloSessionProvider);

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(soundEngineProvider).play(SoundCue.start));
    unawaited(ref.read(vibrationProvider).light());

    final setup = _state.setupOrDefault;
    if (setup.durationSeconds > 0) {
      _remaining = setup.durationSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _remaining--);
        // Bips des 5 dernières secondes.
        if (_remaining > 0 && _remaining <= 5) {
          unawaited(ref.read(soundEngineProvider).play(SoundCue.tick));
        }
        if (_remaining <= 0) {
          _timer?.cancel();
          // Temps écoulé : réponses verrouillées, écran « Temps écoulé ».
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _endTurn(timeUp: true),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _endTurn({bool timeUp = false}) {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    submitAnswers();
    if (mounted) context.pushReplacement(timeUp ? '/time-up' : '/results');
  }

  /// Pousse tous les champs dans le contrôleur puis termine la manche.
  /// `endTurn()` met l'état à jour de façon synchrone (avant son premier
  /// await) : la navigation vers l'écran suivant est donc sûre.
  void submitAnswers() {
    final controller = ref.read(soloSessionProvider.notifier);
    for (final entry in _controllers.entries) {
      controller.setAnswer(entry.key, entry.value.text);
    }
    unawaited(ref.read(soundEngineProvider).play(SoundCue.validate));
    unawaited(ref.read(vibrationProvider).medium());
    unawaited(controller.endTurn());
  }

  TextEditingController _controllerFor(String category) =>
      _controllers.putIfAbsent(category, TextEditingController.new);

  int get _filledCount =>
      _controllers.values.where((c) => c.text.trim().isNotEmpty).length;

  bool get _allFilled => _state.setupOrDefault.categories.every(
    (c) => _controllers[c]?.text.trim().isNotEmpty ?? false,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soloSessionProvider);
    final setup = state.setupOrDefault;
    final noTimer = setup.durationSeconds == 0;
    final alert = !noTimer && _remaining <= 10;
    final total = setup.categories.length;

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.24,
      skylineHeight: 220,
      alertFrame: alert,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête : chrono, manche, avatar.
          Row(
            children: [
              _TimerRing(
                remaining: _remaining,
                total: setup.durationSeconds,
                alert: alert,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANCHE ${state.round} / ${setup.rounds}',
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 24,
                        color: AppColors.offWhite,
                      ),
                    ),
                    Text(
                      noTimer ? 'Sans chrono' : 'Temps restant',
                      style: const TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.offWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const PlayerAvatar(
                asset: 'assets/images/avatar_toi.png',
                size: 54,
                ringWidth: 3,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progression des réponses.
          Row(
            children: [
              Text(
                '$_filledCount / $total réponses',
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueGray,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GradientProgressBar(
                  value: total == 0 ? 0 : _filledCount / total,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grande tuile de la lettre.
          Center(
            child: LetterTile(
              letter: state.letter,
              size: 86,
              rotation: alert ? 0.08 : 0,
            ),
          ),
          const SizedBox(height: 20),

          // Lignes de réponse.
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: total,
              itemBuilder: (context, i) {
                final category = setup.categories[i];
                final last = i == total - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ResponseRow(
                    key: ValueKey(category),
                    category: category,
                    iconName: categoryIconName(category),
                    alert: alert,
                    controller: _controllerFor(category),
                    textInputAction: last
                        ? TextInputAction.done
                        : TextInputAction.next,
                    // Se reconstruire à la saisie : progression et STOP
                    // reflètent les champs en direct.
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (last) FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          if (!noTimer)
            ArcadeButton(
              label: 'Valider',
              variant: ArcadeButtonVariant.green,
              onPressed: _endTurn,
            )
          else
            ArcadeButton(
              label: 'Stop',
              variant: ArcadeButtonVariant.red,
              onPressed: _allFilled ? _endTurn : null,
            ),
        ],
      ),
    );
  }
}

/// Chronomètre rond de la maquette : anneau jaune (corail en alerte)
/// avec un petit bouton au sommet, disque sombre et secondes au centre.
/// L'arc se vide au fil du temps.
class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.remaining,
    required this.total,
    required this.alert,
  });

  final int remaining;
  final int total;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.coral : AppColors.yellow;
    final noTimer = total == 0;
    final progress = noTimer ? 1.0 : (remaining / total).clamp(0.0, 1.0);
    return Semantics(
      label: noTimer ? 'Sans chrono' : 'Temps restant : $remaining secondes',
      liveRegion: alert,
      child: SizedBox(
        width: 80,
        height: 86,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Bouton du chronomètre.
            Positioned(
              top: 0,
              child: Container(
                width: 16,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _RingPainter(progress: progress, color: color),
                child: Center(
                  child: noTimer
                      ? WordstormIcons.clock(size: 28, color: AppColors.teal)
                      : Text(
                          '$remaining',
                          style: TextStyle(
                            fontFamily: AppTheme.monoFont,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: alert ? AppColors.coral : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    // Disque sombre.
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()..color = const Color(0xFF0C1429),
    );
    // Piste de l'anneau.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = color.withAlpha(0x40);
    canvas.drawCircle(center, radius - 5, stroke);
    // Arc restant.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      stroke
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
