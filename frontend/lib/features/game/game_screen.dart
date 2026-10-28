import 'dart:async';

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
import 'state/solo_session.dart';

/// Écran de manche (Figma 05/11) : anneau de chrono, progression
/// « n / N réponses », tuile de lettre, lignes de réponse.
/// - Chrono (20–120 s) : fin automatique à 0 (heure côté client en solo ;
///   le serveur fixera l'heure de fin en ligne, phase 7) ;
/// - Sans chrono : bouton STOP, grisé tant que toutes les catégories ne
///   sont pas remplies (paquet de la maquette).
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Timer? _timer;
  int _remaining = 0;

  SoloSessionState get _state => ref.read(soloSessionProvider);

  @override
  void initState() {
    super.initState();
    // Son + vibration de démarrage de manche (phase 6, best-effort).
    unawaited(ref.read(soundEngineProvider).play(SoundCue.start));
    unawaited(ref.read(vibrationProvider).light());

    final setup = _state.setupOrDefault;
    if (setup.durationSeconds > 0) {
      _remaining = setup.durationSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _remaining--;
        });
        // Blips des 5 dernières secondes (PLAN phase 6) — pas à 0 : la
        // validation auto prend le relais.
        if (_remaining > 0 && _remaining <= 5) {
          unawaited(ref.read(soundEngineProvider).play(SoundCue.tick));
        }
        if (_remaining <= 0) {
          _timer?.cancel();
          // Fin du temps : validation automatique, puis écran de résultats.
          WidgetsBinding.instance.addPostFrameCallback((_) => _endTurn());
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

  void _endTurn() {
    submitAnswers();
    if (mounted) context.pushReplacement('/results');
  }

  /// Pousse tous les champs dans le contrôleur puis termine la manche.
  /// `endTurn()` met l'état à jour de façon synchrone (avant son premier
  /// await) : la navigation vers les résultats est donc sûre sans attente.
  void submitAnswers() {
    final controller = ref.read(soloSessionProvider.notifier);
    for (final entry in _controllers.entries) {
      controller.setAnswer(entry.key, entry.value.text);
    }
    // Son + vibration de validation (phase 6, best-effort).
    unawaited(ref.read(soundEngineProvider).play(SoundCue.validate));
    unawaited(ref.read(vibrationProvider).medium());
    unawaited(controller.endTurn());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soloSessionProvider);
    final setup = state.setupOrDefault;
    final noTimer = setup.durationSeconds == 0;
    final total = setup.categories.length;

    final rows = [
      for (final category in setup.categories)
        ResponseRow(
          key: ValueKey(category),
          category: category,
          iconName: categoryIconName(category),
          // Se reconstruire à la saisie : la progression « n / N » et
          // l'enablement du STOP (sans chrono) doivent refléter les
          // champs en direct.
          onChanged: (_) => setState(() {}),
          controller: _controllerFor(category),
          onSubmitted: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
            if (noTimer && _allFilled) _endTurn();
          },
        ),
    ];

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.1,
      skylineHeight: 240,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Column(
        children: [
          // En-tête : anneau de chrono + manche (maquette).
          Row(
            children: [
              _TimerRing(remaining: _remaining, total: setup.durationSeconds),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANCHE ${state.round} / ${setup.rounds}',
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 22,
                        color: AppColors.offWhite,
                      ),
                    ),
                    Text(
                      noTimer ? 'Sans chronomètre' : 'Temps restant',
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

          // Progression « n / N réponses » avec barre.
          Row(
            children: [
              Text(
                '$_filledCount / $total réponses',
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
                    value: total == 0 ? 0 : _filledCount / total,
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

          // Grosse tuile de la lettre tirée.
          Center(child: LetterTile(letter: state.letter, size: 100)),
          const SizedBox(height: 8),

          // Lignes de réponses.
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: rows[i],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // CTA : VALIDER (chrono) · STOP (sans chrono, grisé jusqu'à
          // remplissage complet de la liste — paquet maquette).
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

  TextEditingController _controllerFor(String category) =>
      _controllers.putIfAbsent(category, TextEditingController.new);

  int get _filledCount =>
      _controllers.values.where((c) => c.text.trim().isNotEmpty).length;

  bool get _allFilled {
    final setup = _state.setupOrDefault;
    return setup.categories.every(
      (c) => _controllers[c]?.text.trim().isNotEmpty ?? false,
    );
  }
}

/// Anneau de chrono (maquette) : jaune, rouge dans les 10 dernières
/// secondes ; « ∞ » quand il n'y a pas de chrono.
class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final noTimer = total == 0;
    final red = !noTimer && remaining <= 10;
    final color = red ? AppColors.coral : AppColors.yellow;
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: noTimer ? 1 : remaining / total,
              strokeWidth: 9,
              backgroundColor: const Color(0xFF0B1330),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            noTimer ? '∞' : '$remaining',
            style: TextStyle(
              fontFamily: AppTheme.monoFont,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: red ? AppColors.coral : AppColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }
}
