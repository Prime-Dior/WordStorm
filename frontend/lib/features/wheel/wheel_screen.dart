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
import '../../core/widgets/screen_scaffold.dart';
import '../../domain/draws.dart';

/// Écran de tirage de la lettre (Figma 10) : la roue s'arrête sur la
/// lettre **tirée par le moteur** (une lettre ne sort pas deux fois dans
/// la même partie). Décélération relevée de la maquette : 3,4 s,
/// courbe cubic-bezier(.12,.75,.1,1) ≈ easeOutCubic, +1440° avant arrêt.
///
/// À l'arrêt, la lettre apparaît au centre et le bouton « C'est parti »
/// lance la manche (maquette `#wheel`).
class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen>
    with SingleTickerProviderStateMixin {
  static const double _wheelSize = 300;

  AnimationController? _spin;
  late final List<String> _letters;
  String letter = '';
  double _angle = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Lettres de la roue : le tirage normal, plus K W X Y Z si l'option
    // « lettres difficiles » est active (sinon la roue ne contiendrait
    // pas la lettre tirée).
    final pool = Draws.defaultPool.split('');
    if (ref.read(soloSessionProvider).setupOrDefault.allowHardLetters) {
      for (final c in 'KWXYZ'.split('')) {
        if (!pool.contains(c)) pool.add(c);
      }
    }
    _letters = pool;

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
      setState(() {
        _angle = target;
        _done = true;
      });
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
        // La roue est arrêtée : on révèle la lettre et le bouton.
        setState(() => _done = true);
      }
    });
    spin.forward();
  }

  @override
  void dispose() {
    _spin?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soloSessionProvider);
    final rounds = state.setupOrDefault.rounds;
    final roundLabel = 'Manche ${state.round} / $rounds';

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.42,
      skylineHeight: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TIRAGE DE LA LETTRE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 34,
              color: AppColors.offWhite,
            ),
          ),
          const SizedBox(height: 28),

          // Roue + pointeur + disque central.
          Center(
            child: SizedBox(
              width: _wheelSize,
              height: _wheelSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _angle,
                    child: CustomPaint(
                      size: const Size(_wheelSize, _wheelSize),
                      painter: _WheelPainter(letters: _letters),
                    ),
                  ),
                  // Disque central avec la lettre tirée (« pop » à l'arrêt).
                  Container(
                    width: _wheelSize * 0.42,
                    height: _wheelSize * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navyBlue,
                      border: Border.all(
                        color: const Color(0xFF0B1222),
                        width: 5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedScale(
                      scale: _done ? 1 : 0.3,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: _done ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontFamily: AppTheme.displayFont,
                            fontSize: 72,
                            color: AppColors.yellow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pointeur blanc en haut, pointe vers la roue.
                  const Positioned(
                    top: -18,
                    child: CustomPaint(
                      size: Size(32, 40),
                      painter: _PointerPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            _done
                ? '$roundLabel · lettre $letter'
                : '$roundLabel · la roue tourne…',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.offWhite,
            ),
          ),
          const Spacer(),

          // « C'est parti » : visible seulement quand la roue est arrêtée.
          Opacity(
            opacity: _done ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_done,
              child: ArcadeButton(
                label: "C'est parti",
                variant: ArcadeButtonVariant.green,
                onPressed: () => context.pushReplacement('/game'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Roue peinte (maquette) : 4 quarts de couleur (jaune, turquoise,
/// corail, violet), bordure sombre, lettres posées sur le pourtour.
/// La lettre d'index 0 est centrée sous le pointeur (haut) à angle 0.
class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.letters});

  final List<String> letters;

  static const _quarters = [
    AppColors.yellow,
    AppColors.teal,
    AppColors.coral,
    Color(0xFF7B61FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    final n = letters.length;
    final segment = 2 * math.pi / n;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Ombre portée de la roue.
    canvas.drawCircle(
      c.translate(0, 8),
      r,
      Paint()..color = const Color(0xFF0B1222),
    );

    // Segments : la couleur dépend du quart où se trouve la lettre.
    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < n; i++) {
      fill.color = _quarters[(i * 4 ~/ n) % 4];
      final start = segment * i - segment / 2 - math.pi / 2;
      canvas.drawArc(rect, start, segment + 0.01, true, fill);
    }

    // Bordure sombre.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = const Color(0xFF0B1222),
    );

    // Lettres, tournées dans le sens de la roue.
    for (var i = 0; i < n; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 28,
            color: AppColors.navyBlue,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(segment * i);
      canvas.translate(-tp.width / 2, -r * 0.80 - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.letters != letters;
}

/// Pointeur blanc triangulaire (pointe vers le bas).
class _PointerPainter extends CustomPainter {
  const _PointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, const Color(0xFF000000), 3, true);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}
