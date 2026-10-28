import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../controllers/multiplayer_controller.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, this.setup});

  final Object? setup;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _multi = Get.find<MultiplayerController>();

  @override
  void initState() {
    super.initState();
    _multi.refreshRoom();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final session = _multi.session.value;
    final players = _multi.room['players'] as List? ?? const [];
    final setup = session?.setup;
    final canStart = players.length >= 2 && session?.isHost == true;

    return ScreenScaffold(
      skylineHeight: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Retour',
                onPressed: _multi.leaveToMenu,
                icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
              ),
              const Expanded(
                child: Text(
                  'SALON MULTIJOUEUR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 26,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xCC000000),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'CODE DU SALON',
                    style: TextStyle(
                      color: AppColors.blueGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  session?.code ?? '…',
                  style: const TextStyle(
                    fontFamily: AppTheme.monoFont,
                    fontSize: 24,
                    color: AppColors.yellow,
                    letterSpacing: 3,
                  ),
                ),
                IconButton(
                  tooltip: 'Copier le code',
                  onPressed: session == null
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: session.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copié.')),
                          );
                        },
                  icon: const Icon(Icons.copy, color: AppColors.offWhite),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'JOUEURS',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 21,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              Text(
                '${players.length} / 8',
                style: const TextStyle(
                  color: AppColors.blueGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (final player in players)
                  ListTile(
                    leading: Icon(
                      player['is_host'] == true ? Icons.star : Icons.person,
                      color: AppColors.teal,
                    ),
                    title: Text(
                      '${player['nickname']}',
                      style: const TextStyle(
                        color: AppColors.offWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: player['is_host'] == true
                        ? const Text(
                            'HÔTE',
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontSize: 11,
                            ),
                          )
                        : null,
                  ),
                if (setup != null)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${setup.rounds} manches · '
                      '${setup.durationSeconds == 0 ? 'Sans chrono' : '${setup.durationSeconds} s'}\n'
                      '${setup.categories.join(' · ')}',
                      style: const TextStyle(
                        color: AppColors.blueGray,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_multi.error.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _multi.error.value!,
                style: const TextStyle(color: AppColors.coral),
              ),
            ),
          if (session?.isHost == true && _multi.room['status'] == 'waiting')
            ArcadeButton(
              label: canStart ? 'Démarrer' : 'En attente d’un joueur',
              variant: ArcadeButtonVariant.teal,
              onPressed: canStart && !_multi.busy.value
                  ? _multi.startGame
                  : null,
            )
          else if (_multi.room['status'] == 'in_progress')
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Salon démarré côté API. Les écrans de jeu multijoueur restent à réaliser.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.yellow),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'En attente du démarrage par l’hôte…',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blueGray),
              ),
            ),
          const SizedBox(height: 8),
          ArcadeButton(
            label: 'Quitter le salon',
            variant: ArcadeButtonVariant.dark,
            small: true,
            onPressed: _multi.leaveToMenu,
          ),
        ],
      ),
    );
  });
}
