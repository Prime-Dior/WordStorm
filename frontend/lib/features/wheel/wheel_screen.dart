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
import '../../core/widgets/ui_kit.dart';
import '../../domain/draws.dart';

/// Écran « Tirage de la lettre » (maquette 10).
///
/// La roue à quatre couleurs tourne puis s'arrête sous le pointeur sur
/// la lettre **tirée par le moteur** (pas deux fois la même lettre dans
/// une partie). Décélération relevée de la maquette : 3,4 s, courbe
/// proche d'easeOutCubic, quatre tours complets avant l'arrêt.
/// Le bouton « C'EST PARTI » s'active quand la roue est arrêtée.
class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _spin;
  List<String> _letters = Draws.defaultPool.split('');
  String _letter = '';
  double _angle = 0;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    // Le tirage est différé après la construction : riverpod interdit de
    // modifier un provider pendant que l'arbre se construit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSpin();
    });
  }

  void _startSpin() {
    // 1. Le moteur tire la lettre de la manche (un tirage par manche).
    final session = ref.read(soloSessionProvider);
    ref.read(soloSessionProvider.notifier).drawLetter();
    final letter = ref.read(soloSessionProvider).letter;

    // Roue complète (A à Z) si les lettres difficiles sont autorisées.
    final letters = session.setupOrDefault.allowHardLetters
        ? List.generate(26, (i) => String.fromCharCode(65 + i))
        : Draws.defaultPool.split('');
    if (!letters.contains(letter)) letters.add(letter);

    setState(() {
      _letters = letters;
      _letter = letter;
    });

    // 2. Angle d'arrêt : la lettre tirée sous le pointeur (en haut).
    final index = letters.indexOf(letter);
    final segment = 2 * math.pi / letters.length;
    const fullTurns = 4 * 2 * math.pi;
    final target = fullTurns - index * segment;

    unawaited(ref.read(soundEngineProvider).play(SoundCue.wheel));
    unawaited(ref.read(vibrationProvider).heavy());

    // Animations réduites : la roue s'arrête directement sur la lettre.
    if (MediaQuery.of(context).disableAnimations) {
      setState(() {
        _angle = target;
        _stopped = true;
      });
      return;
    }

    final spin = _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    final curved = CurvedAnimation(parent: spin, curve: Curves.easeOutCubic);
    curved.addListener(() {
      if (mounted) setState(() => _angle = curved.value * target);
    });
    curved.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _stopped = true);
      }
    });
    spin.forward();
  }

  /// Lettre actuellement sous le pointeur (affichée au centre).
  String get _letterUnderPointer {
    if (_stopped || _letters.isEmpty) return _letter;
    final segment = 2 * math.pi / _letters.length;
    final turned = (-_angle) % (2 * math.pi);
    final index = (turned / segment).round() % _letters.length;
    return _letters[index];
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
    final caption = _stopped
        ? 'Manche ${state.round} / $rounds · lettre $_letter'
        : 'Manche ${state.round} / $rounds · tirage en cours…';

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.4,
      skylineHeight: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const ScreenTitle('Tirage de la lettre', fontSize: 30),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Wheel(
                    angle: _angle,
                    letters: _letters,
                    centerLetter: _letterUnderPointer,
                    stopped: _stopped,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    caption,
                    style: const TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ArcadeButton(
            label: 'C’est parti',
            variant: ArcadeButtonVariant.green,
            onPressed: _stopped ? () => context.pushReplacement('/game') : null,
          ),
        ],
      ),
    );
  }
}

/// Roue complète : disque peint, pointeur blanc, moyeu central.
class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.angle,
    required this.letters,
    required this.centerLetter,
    required this.stopped,
  });

  static const double size = 300;

  final double angle;
  final List<String> letters;
  final String centerLetter;
  final bool stopped;

  @override
  Widget build(BuildContext context) => Semantics(
    label: stopped ? 'Lettre tirée : $centerLetter' : 'La roue tourne',
    liveRegion: true,
    child: SizedBox(
      width: size,
      height: size + 22,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 22,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x88000000),
                    offset: Offset(0, 14),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WheelPainter(letters: letters, angle: angle),
                ),
              ),
            ),
          ),
          // Moyeu central : grande lettre jaune.
          Positioned(
            top: 22 + size / 2 - 52,
            child: Container(
              width: 104,
              height: 104,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyBlue,
                border: Border.all(color: const Color(0xFF0C1429), width: 6),
              ),
              child: AnimatedScale(
                scale: stopped ? 1.15 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Text(
                  centerLetter,
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 62,
                    height: 1,
                    color: AppColors.yellow,
                  ),
                ),
              ),
            ),
          ),
          // Pointeur blanc en haut.
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(30, 44),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.letters, required this.angle});

  final List<String> letters;
  final double angle;

  // Quatre quartiers de la maquette, dans le sens des aiguilles d'une
  // montre à partir du haut.
  static const List<Color> _quarters = [
    Color(0xFF8962EF),
    AppColors.yellow,
    AppColors.teal,
    AppColors.coral,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Quartiers de couleur.
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius - 6);
    const quarter = math.pi / 2;
    for (var i = 0; i < 4; i++) {
      final start = -math.pi / 2 - 0.15 + i * quarter;
      canvas.drawArc(rect, start, quarter, true, Paint()..color = _quarters[i]);
    }

    // Lettres sur le pourtour, tournées vers l'extérieur.
    final segment = 2 * math.pi / letters.length;
    final textRadius = radius - 30;
    for (var i = 0; i < letters.length; i++) {
      final a = segment * i;
      canvas.save();
      canvas.rotate(a);
      canvas.translate(0, -textRadius);
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 24,
            color: AppColors.navyBlue,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.restore();

    // Jante sombre (ne tourne pas : elle est symétrique).
    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF0C1429),
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.letters != letters;
}

/// Pointeur triangulaire blanc, pointe vers le bas.
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, Paint()..color = AppColors.offWhite);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}
