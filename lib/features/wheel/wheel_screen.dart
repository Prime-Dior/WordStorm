import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/audio/sound_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../domain/draws.dart';

/// Écran de tirage de la lettre (Figma 10) : la roue s'arrête sur la
/// lettre **tirée par le moteur** (une lettre ne sort pas deux fois dans
/// la même partie). Décélération relevée de la maquette : 3,4 s,
/// courbe cubic-bezier(.12,.75,.1,1) ≈ easeOutCubic, +1440° avant arrêt.
///
/// L'habillage complet (pointeur pivot, anneau central, tick sonore) est
/// affiné à la phase 8 ; la mécanique de tirage est exacte dès la phase 4.
class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _spin;
  late final List<String> _letters = Draws.defaultPool.split('');
  String letter = '';

  @override
  void initState() {
    super.initState();
    // Le tirage + le démarrage de la roue sont différés **après** la
    // construction : riverpod interdit de modifier un provider pendant
    // que l'arbre est en cours de construction (rien dans initState).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSpin();
    });
  }

  void _startSpin() {
    // 1. Le moteur tire la lettre de la manche (un tirage par manche).
    ref.read(soloSessionProvider.notifier).drawLetter();
    letter = ref.read(soloSessionProvider).letter;

    // 2. Cible l'angle qui arrête la roue sous le pointeur (haut).
    final index = _letters.indexOf(letter);
    final segment = 2 * math.pi / _letters.length;
    // Le pointeur est en haut ; il faut -(index * segment) + manches.
    const fullTurns = 1440 * math.pi / 180;
    final target = fullTurns - index * segment;

    // Son + vibration (phase 6, best-effort : aucun impact sur le flux).
    unawaited(ref.read(soundEngineProvider).play(SoundCue.wheel));
    unawaited(ref.read(vibrationProvider).heavy());

    // Accessibilité (phase 6) : « animations réduites » du système →
    // la lettre apparaît immédiatement, aucune animation de roue.
    if (MediaQuery.of(context).disableAnimations) {
      setState(() => _angle = target);
      context.pushReplacement('/game');
      return;
    }

    final spin = _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    final curved = CurvedAnimation(parent: spin, curve: Curves.easeOutCubic);
    curved.addListener(() {
      if (!mounted) return;
      setState(() => _angle = curved.value * target);
    });
    curved.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.pushReplacement('/game');
      }
    });
    // Navigation automatique vers la manche quand la roue s'arrête
    // (enregistré une seule fois).
    spin.forward();
  }

  double _angle = 0;

  @override
  void dispose() {
    _spin?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.3,
      skylineHeight: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MANCHE ${ref.watch(soloSessionProvider).round}',
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 22,
                color: AppColors.yellow,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 330,
              height: 330,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _WheelPaint(angle: _angle, letters: _letters),
                  // Pointeur.
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 14,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Disque central.
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navyBlue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(0x55),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 52,
                        color: AppColors.yellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Roue peinte : segments de lettres tournants, encre encre après ton
/// remplissage (mania con?). La teinte « jaune » vient de la maquette.
class _WheelPaint extends StatelessWidget {
  const _WheelPaint({required this.angle, required this.letters});

  final double angle;
  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: 330,
        height: 330,
        child: CustomPaint(
          isComplex: true,
          painter: _WheelPainter(letters: letters),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.letters});

  final List<String> letters;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final segment = 2 * math.pi / letters.length;

    final sectionPaint = Paint()..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.bgTop;

    for (var i = 0; i < letters.length; i++) {
      final start = segment * i - segment / 2 - math.pi / 2;

      sectionPaint.color = i % 2 == 0
          ? AppColors.bgTop.withAlpha(0x99)
          : const Color(0x11FFFFFF);

      final rect = Rect.fromCircle(center: c, radius: r - 32);
      canvas.drawArc(rect, start, segment, true, sectionPaint);
      canvas.drawArc(rect, start, segment, true, outlinePaint);

      // Lettre : Bangers, tournée vers le centre du segment.
      final mid = start + segment / 2;
      final wordPos = c.translate(
        (size.width / 2 - 26) * math.cos(mid),
        (size.height / 2 - 26) * math.sin(mid),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 22,
            color: AppColors.offWhite,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final offset = Offset(
        wordPos.dx - textPainter.width / 2,
        wordPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.letters != letters;
}
