import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/player_card.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../domain/models/lobby_preview.dart';
import '../../../domain/models/lobby_setup.dart';
import '../../controllers/page_controllers.dart';

/// Aperçu local de l'écran de salon ; la création en ligne sera branchée à l'API.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, this.preview});

  final LobbyPreview? preview;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final LobbyPreview? _preview;
  late final LobbyController _controller;

  String get _code => _controller.code;
  LobbySetup? get _setup {
    final room = _controller.room.value;
    if (room == null) return _preview?.setup;

    return LobbySetup(
      categories: room.configuration.categories,
      durationSeconds: room.configuration.durationSeconds,
      rounds: room.configuration.roundCount,
      allowHardLetters: room.configuration.allowHardLetters,
      randomCategories: room.configuration.categoryMode == 'random',
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LobbyController>();
    _preview = widget.preview ?? _controller.preview;
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Code du salon copié.')));
  }

  String _durationLabel(int seconds) =>
      seconds == 0 ? 'Sans chrono' : '$seconds s / manche';

  @override
  Widget build(BuildContext context) {
    final setup = _setup;
    return ScreenScaffold(
      skylineHeight: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Quitter le salon',
                onPressed: _controller.leaveRoom,
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
          const SizedBox(height: 14),
          Obx(() => _CodePanel(code: _code, onCopy: _copyCode)),
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
              Obx(
                () => Text(
                  _controller.room.value == null
                      ? 'Connexion au salon…'
                      : '${_controller.room.value!.players.length} / 8 joueurs',
                  style: const TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.blueGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final currentRoom = _controller.room.value;
            if (currentRoom == null) {
              return _controller.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      _controller.error.value ?? 'Salon indisponible.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.coral),
                    );
            }

            return Column(
              children: [
                for (final player in currentRoom.players) ...[
                  PlayerCard(
                    name: player.isHost
                        ? '${player.nickname} · Hôte'
                        : player.nickname,
                    host: player.isHost,
                    avatar: player.nickname == _controller.nickname
                        ? 'assets/images/avatar_toi.png'
                        : null,
                  ),
                  const SizedBox(height: 7),
                ],
                if (currentRoom.players.length < 8)
                  _EmptyPlacesPreview(count: 8 - currentRoom.players.length),
              ],
            );
          }),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: setup == null
                  ? const _JoinPreviewNotice()
                  : _SetupSummary(
                      setup: setup,
                      durationLabel: _durationLabel(setup.durationSeconds),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final currentRoom = _controller.room.value;
            final canStart =
                _controller.isHost &&
                currentRoom?.status == 'waiting' &&
                (currentRoom?.players.length ?? 0) >= 2 &&
                !_controller.isStarting.value;

            final label = _controller.isStarting.value
                ? 'Démarrage…'
                : !_controller.isHost
                ? 'En attente de l’hôte'
                : currentRoom == null
                ? 'Chargement du salon…'
                : currentRoom.players.length < 2
                ? 'En attente d’un joueur'
                : currentRoom.status == 'in_progress'
                ? 'Partie en cours…'
                : 'Démarrer la partie';

            return ArcadeButton(
              label: label,
              variant: ArcadeButtonVariant.teal,
              onPressed: canStart ? _controller.startGame : null,
            );
          }),
          Obx(() {
            final message = _controller.error.value;
            if (message == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.coral),
              ),
            );
          }),
          const SizedBox(height: 8),
          ArcadeButton(
            label: 'Quitter le salon',
            variant: ArcadeButtonVariant.dark,
            small: true,
            onPressed: _controller.leaveRoom,
          ),
        ],
      ),
    );
  }
}

class _JoinPreviewNotice extends StatelessWidget {
  const _JoinPreviewNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Aperçu local uniquement. Les détails du salon seront chargés après la connexion au serveur.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 12,
        color: AppColors.blueGray,
      ),
    ),
  );
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xCC000000),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x33FFFFFF)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'CODE DU SALON',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.blueGray,
            ),
          ),
        ),
        Text(
          code,
          style: const TextStyle(
            fontFamily: AppTheme.monoFont,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.yellow,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Copier le code local',
          onPressed: onCopy,
          icon: const Icon(Icons.copy, color: AppColors.offWhite, size: 20),
        ),
      ],
    ),
  );
}

/// Indique combien de places restent dans le salon.
class _EmptyPlacesPreview extends StatelessWidget {
  const _EmptyPlacesPreview({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x12FFFFFF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x22FFFFFF)),
    ),
    child: Row(
      children: [
        const Icon(Icons.group_outlined, color: AppColors.blueGray, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$count place${count == 1 ? '' : 's'} libre${count == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              color: AppColors.blueGray,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SetupSummary extends StatelessWidget {
  const _SetupSummary({required this.setup, required this.durationLabel});

  final LobbySetup setup;
  final String durationLabel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PARAMÈTRES DE LA PARTIE',
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 18,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${setup.rounds} manche${setup.rounds == 1 ? '' : 's'} · $durationLabel',
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.offWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Catégories ${setup.randomCategories ? 'aléatoires (figées)' : 'personnalisées'} · '
          'lettres difficiles ${setup.allowHardLetters ? 'activées' : 'désactivées'}',
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 11,
            color: AppColors.blueGray,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: setup.categories
              .map((category) => _CategoryChip(category))
              .toList(growable: false),
        ),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.navyBlue,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.teal.withAlpha(0x88)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 10,
        color: AppColors.offWhite,
      ),
    ),
  );
}
