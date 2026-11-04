import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/audio/sound_engine.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/ui_kit.dart';

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

/// Classe les joueurs avec les scores reçus de l'API.
class PodiumScreen extends StatefulWidget {
  const PodiumScreen({super.key, this.entries});

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
    final myRank = ranking.indexWhere((player) => player.me) + 1;

    final message = myRank == 0
        ? 'Partie terminée.'
        : myRank == 1
        ? 'Tu remportes la partie !'
        : 'Tu termines ${myRank}e sur ${ranking.length}.';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const ScreenTitle('Classement final'),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: ranking.isEmpty
                ? const Center(child: Text('Aucun score reçu.'))
                : ListView.separated(
                    itemCount: ranking.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = ranking[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: player.me
                              ? const Color(0xFF25476A)
                              : kPanelColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.yellow,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            player.me ? '${player.name} · Toi' : player.name,
                          ),
                          trailing: Text(
                            '${player.score} pts',
                            style: const TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
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
