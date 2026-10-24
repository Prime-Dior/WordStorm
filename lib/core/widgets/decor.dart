import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Décor de fond : silhouette d'immeubles aux fenêtres allumées (`.bgc` de
/// la maquette) — jour sur l'accueil, nuit ailleurs.
class CitySkyline extends StatelessWidget {
  const CitySkyline({this.day = false, this.height = 420, super.key});

  static const List<Color> _dayColors = [
    Color(0xFF4A7BD0),
    Color(0xFF8B5FD0),
    Color(0xFFE0587F),
    Color(0xFFF0983F),
    Color(0xFF2FA6A0),
  ];
  static const List<Color> _nightColors = [
    Color(0xFF1A2A55),
    Color(0xFF22346A),
    Color(0xFF16224A),
    Color(0xFF2A4080),
  ];

  final bool day;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          isComplex: true,
          painter: _CitySkylinePainter(day: day),
        ),
      ),
    );
  }
}

class _CitySkylinePainter extends CustomPainter {
  _CitySkylinePainter({required this.day});

  static const List<double> _heights = [
    210,
    140,
    260,
    180,
    300,
    160,
    230,
    120,
    250,
    170,
  ];
  static const List<double> _widths = [44, 38, 56, 40, 50, 36, 52, 42, 46, 40];

  final bool day;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = day ? CitySkyline._dayColors : CitySkyline._nightColors;
    final windowColor = day
        ? const Color(0x66FFFFFF) // `--wn:#ffffff66`
        : const Color(0x99FFE27A); // `--wn:#ffe27a99`

    for (var i = 0; i < _heights.length; i++) {
      final h = _heights[i] * (day ? 1.0 : 0.9);
      final w = _widths[i];
      final slot = size.width / _heights.length;
      final x = i * slot + (slot - w) / 2;
      final top = size.height - h;
      final color = colors[i % colors.length];

      final rect = Rect.fromLTRB(x, top, x + w, size.height);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rrect, Paint()..color = color);

      // Ombre latérale (CSS `inset -8px 0 0 #0003`).
      canvas.drawRect(
        Rect.fromLTRB(rect.right - 8, top + 3, rect.right, size.height),
        Paint()..color = const Color(0x30000000),
      );

      // Fenêtres : rangées 20px, colonnes 18px (CSS repeating gradients).
      final windowPaint = Paint()..color = windowColor;
      const rowStep = 20.0;
      const rowHeight = 8.0;
      const colStep = 18.0;
      const colWidth = 9.0;

      var y = top + 14;
      while (y + rowHeight < size.height - 4) {
        var wx = x + 8;
        while (wx + colWidth < rect.right - 8) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(wx, y, wx + colWidth, y + rowHeight),
              const Radius.circular(1.5),
            ),
            windowPaint,
          );
          wx += colStep;
        }
        y += rowStep;
      }
    }

    // Fondu haut (CSS linear-gradient transparent → #14204088).
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00142040), Color(0x88142040)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _CitySkylinePainter oldDelegate) =>
      oldDelegate.day != day;
}

/// Rayons lumineux tournants derrière les éléments clés (`.burst`).
/// Faisceaux blancs semi-transparents tournant lentement en continu.
class Sunburst extends StatefulWidget {
  const Sunburst({
    super.key,
    this.size = 560,
    this.baseAlpha = 0x11,
    this.durationSecs = 60,
  });

  final double size;
  final int baseAlpha;
  final int durationSecs;

  @override
  State<Sunburst> createState() => _SunburstState();
}

class _SunburstState extends State<Sunburst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSecs),
    );
    _spin.forward();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RotationTransition(
        turns: _spin,
        child: CustomPaint(
          size: Size.square(widget.size),
          isComplex: true,
          painter: _SunburstPainter(baseAlpha: widget.baseAlpha),
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  _SunburstPainter({required this.baseAlpha});

  final int baseAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final inner = size.width * 0.05;
    final outer = size.width * 0.68 * 0.5;

    final paint = Paint()..color = Color.fromARGB(baseAlpha, 255, 255, 255);

    // `repeating-conic-gradient(#fff3 0 7deg, transparent 7deg 18deg)`.
    var a = 0.0;
    while (a < 2 * math.pi) {
      final aEnd = a + 7 * math.pi / 180;
      final path = Path()
        ..moveTo(c.dx + inner * math.cos(a), c.dy + inner * math.sin(a))
        ..lineTo(c.dx + outer * math.cos(a), c.dy + outer * math.sin(a))
        ..lineTo(c.dx + outer * math.cos(aEnd), c.dy + outer * math.sin(aEnd))
        ..lineTo(c.dx + inner * math.cos(aEnd), c.dy + inner * math.sin(aEnd))
        ..close();
      canvas.drawPath(path, paint);
      a += 18 * math.pi / 180;
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.baseAlpha != baseAlpha;
}
