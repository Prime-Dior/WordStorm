import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/audio/sound_engine.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/ui_kit.dart';

/// Un joueur classé, transmis au podium (`Get.arguments`).
class PodiumEntry {
  const PodiumEntry({
    required this.name,
    required this.avatar,
    required this.score,
    this.me = false,
  });

  final String name;
  final String avatar;
  final int score;
  final bool me;
}

/// Classement final multijoueur (maquette 13) : podium à trois marches
/// qui montent l'une après l'autre, confettis, joueurs suivants en
/// dessous, boutons REJOUER et MENU.
///
/// Le classement ([PodiumEntry]) est fourni par l'appelant, à partir des
/// scores multijoueur de l'API :
/// `Get.toNamed(AppRoutes.podium, arguments: <PodiumEntry>[...])`.
class PodiumScreen extends StatefulWidget {
  const PodiumScreen({super.key, this.entries});

  /// Joueurs à classer ; par défaut, `Get.arguments`.
  final List<PodiumEntry>? entries;

  @override
  State<PodiumScreen> createState() => _PodiumScreenState();
}

class _PodiumScreenState extends State<PodiumScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(Get.find<SoundEngine>().play(SoundCue.victory));
    unawaited(Get.find<VibrationEngine>().heavy());
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        widget.entries ??
        (Get.arguments is List<PodiumEntry>
            ? Get.arguments as List<PodiumEntry>
            : const <PodiumEntry>[]);
    final ranking = [...entries]..sort((a, b) => b.score.compareTo(a.score));

    final myRank = ranking.indexWhere((r) => r.me) + 1;
    final subtitle = myRank == 0
        ? 'Partie terminée.'
        : myRank == 1
        ? 'Tu remportes la partie !'
        : 'Tu termines ${myRank}e sur ${ranking.length}.';

    return ScreenScaffold(
      showSunburst: true,
      burstTop: 0.3,
      skylineHeight: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const ScreenTitle('Classement final'),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 12,
              color: AppColors.blueGray,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 290,
            child: Stack(
              children: [
                const Positioned.fill(child: _Confetti()),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (ranking.length > 1)
                        Expanded(
                          child: _PodiumStep(player: ranking[1], place: 2),
                        ),
                      if (ranking.isNotEmpty)
                        Expanded(
                          child: _PodiumStep(player: ranking[0], place: 1),
                        ),
                      if (ranking.length > 2)
                        Expanded(
                          child: _PodiumStep(player: ranking[2], place: 3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final p in ranking.skip(3))
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kPanelColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        PlayerAvatar(asset: p.avatar, size: 30, ringWidth: 2),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.offWhite,
                            ),
                          ),
                        ),
                        Text(
                          '${p.score}',
                          style: const TextStyle(
                            fontFamily: AppTheme.monoFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ArcadeButton(
            label: 'Menu',
            variant: ArcadeButtonVariant.dark,
            onPressed: () => Get.offAllNamed<void>(AppRoutes.menu),
          ),
        ],
      ),
    );
  }
}

/// Une marche du podium : avatar, pseudo, score, puis la marche qui
/// monte (la 3e d'abord, puis la 2e, puis la 1re).
class _PodiumStep extends StatelessWidget {
  const _PodiumStep({required this.player, required this.place});

  final PodiumEntry player;
  final int place;

  @override
  Widget build(BuildContext context) {
    final first = place == 1;
    final height = switch (place) {
      1 => 120.0,
      2 => 85.0,
      _ => 62.0,
    };
    // Ordre d'apparition : 3e, 2e, 1re.
    final delay = switch (place) {
      3 => 0.0,
      2 => 0.25,
      _ => 0.5,
    };
    final reduce = MediaQuery.of(context).disableAnimations;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduce ? 1.0 : 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1600),
      builder: (context, t, _) {
        final local = Interval(
          delay,
          math.min(1.0, delay + 0.5),
          curve: Curves.easeOutBack,
        ).transform(t);
        return Opacity(
          opacity: local.clamp(0.0, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerAvatar(
                asset: player.avatar,
                size: first ? 76 : 58,
                ringWidth: 3,
              ),
              const SizedBox(height: 4),
              Text(
                player.name,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
              Text(
                '${player.score}',
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.yellow,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: math.max(0.0, height * local),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: first
                        ? const [AppColors.yellowLight, AppColors.yellow]
                        : const [AppColors.podiumTop, AppColors.podiumBottom],
                  ),
                ),
                child: height * local > 40
                    ? Text(
                        '$place',
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: first ? 46 : 38,
                          color: first ? AppColors.navyBlue : Colors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Confettis qui tombent doucement derrière le podium.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 0.4;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(painter: _ConfettiPainter(_controller)),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    const colors = [AppColors.yellow, AppColors.teal, AppColors.coral];
    for (var i = 0; i < 22; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.6 + random.nextDouble() * 0.8;
      final phase = random.nextDouble();
      final y = ((animation.value * speed + phase) % 1.0) * size.height;
      final angle = random.nextDouble() * math.pi + animation.value * 6;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -1.5, 8, 3),
        Paint()..color = colors[i % colors.length].withAlpha(0xCC),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
