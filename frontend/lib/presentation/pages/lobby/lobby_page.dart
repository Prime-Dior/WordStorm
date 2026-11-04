import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../domain/models/lobby_preview.dart';
import '../../../domain/models/lobby_setup.dart';
import '../../../domain/models/room_model.dart';
import '../../controllers/page_controllers.dart';

/// Affiche le code, les réglages et les joueurs du salon.
class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key, this.preview});

  final LobbyPreview? preview;

  static const _avatars = [
    'assets/images/avatar_lina.png',
    'assets/images/avatar_max.png',
    'assets/images/avatar_sami.png',
  ];

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    Get.snackbar('Code copié', code);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LobbyController>();
    final lobbyPreview = preview ?? controller.preview;

    return ScreenScaffold(
      child: Obx(() {
        final room = controller.room.value;
        final setup = room == null
            ? lobbyPreview?.setup
            : LobbySetup(
                categories: room.configuration.categories,
                durationSeconds: room.configuration.durationSeconds,
                rounds: room.configuration.roundCount,
                allowHardLetters: room.configuration.allowHardLetters,
                randomCategories: room.configuration.categoryMode == 'random',
              );
        final count = room?.players.length ?? 0;
        final canStart =
            controller.isHost &&
            room?.status == 'waiting' &&
            count >= 2 &&
            !controller.isStarting.value;

        String buttonLabel;
        if (controller.isStarting.value) {
          buttonLabel = 'Démarrage…';
        } else if (!controller.isHost) {
          buttonLabel = 'En attente de l’hôte…';
        } else if (room == null) {
          buttonLabel = 'Chargement du salon…';
        } else {
          buttonLabel = 'Démarrer · $count joueur${count == 1 ? '' : 's'}';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: controller.leaveRoom,
                  icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
                ),
                const Expanded(
                  child: Text(
                    'SALON',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.offWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'CODE D’INVITATION',
              style: TextStyle(color: AppColors.blueGray),
            ),
            Card(
              color: const Color(0xFF152440),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        controller.code,
                        style: const TextStyle(
                          color: AppColors.yellow,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.code.isEmpty
                          ? null
                          : () => _copyCode(controller.code),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copier'),
                    ),
                  ],
                ),
              ),
            ),
            if (setup != null) ...[
              const SizedBox(height: 8),
              Text(
                '${setup.randomCategories ? 'Catégories aléatoires' : 'Catégories personnalisées'}'
                ' · ${setup.rounds} manches · '
                '${setup.durationSeconds == 0 ? 'sans chrono' : '${setup.durationSeconds} s'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.offWhite),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  for (final category in setup.categories)
                    Chip(
                      label: Text(category),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: const Color(0x33FFFFFF),
                      labelStyle: const TextStyle(color: AppColors.offWhite),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Joueurs $count / 8',
              style: const TextStyle(color: AppColors.blueGray),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: room == null
                  ? Center(
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : Text(
                              controller.error.value ?? 'Salon indisponible.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.coral),
                            ),
                    )
                  : room.players.isEmpty
                  ? const Center(child: Text('Aucun joueur dans ce salon.'))
                  : ListView(
                      children: [
                        for (var i = 0; i < room.players.length; i++)
                          _playerTile(room, i, controller.nickname),
                      ],
                    ),
            ),
            if (room != null && count < 2 && controller.isHost)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Il faut au moins 2 joueurs pour démarrer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.blueGray),
                ),
              ),
            if (controller.error.value != null)
              Text(
                controller.error.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.coral),
              ),
            const SizedBox(height: 8),
            ArcadeButton(
              label: buttonLabel,
              onPressed: canStart ? controller.startGame : null,
            ),
          ],
        );
      }),
    );
  }

  Widget _playerTile(RoomModel room, int index, String nickname) {
    final player = room.players[index];
    final isMe = player.nickname == nickname;
    final avatar = isMe
        ? 'assets/images/avatar_toi.png'
        : _avatars[(index - 1).abs() % _avatars.length];

    return Card(
      color: const Color(0xFF152440),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: AssetImage(avatar)),
        title: Text(isMe ? '${player.nickname} · Toi' : player.nickname),
        subtitle: player.isHost ? const Text('Hôte') : null,
        trailing: player.isHost
            ? const Icon(Icons.emoji_events, color: AppColors.yellow)
            : null,
      ),
    );
  }
}
