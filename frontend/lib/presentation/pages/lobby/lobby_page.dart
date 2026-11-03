import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/icons/wordstorm_icons.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../domain/models/lobby_preview.dart';
import '../../../domain/models/lobby_setup.dart';
import '../../../domain/models/room_model.dart';
import '../../controllers/page_controllers.dart';

/// Écran du salon multijoueur (maquettes 23, 04 et 09).
///
/// - **Hôte** : code d'invitation copiable, réglages de la partie, liste
///   des joueurs. Seul au départ (« DÉMARRER · 1 JOUEUR » grisé), le
///   bouton s'active dès qu'un invité a rejoint.
/// - **Invité** : même écran, le bouton affiche « EN ATTENTE DE L'HÔTE… ».
///
/// Le salon est actualisé par [LobbyController] (API) ; le retour quitte
/// le salon.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, this.preview});

  final LobbyPreview? preview;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  /// Taille d'un salon (cahier : 2 à 8 joueurs).
  static const int _minPlayers = 2;
  static const int _maxPlayers = 8;

  /// Avatars attribués aux autres joueurs, dans l'ordre d'arrivée.
  static const List<String> _guestAvatars = [
    'assets/images/avatar_lina.png',
    'assets/images/avatar_max.png',
    'assets/images/avatar_sami.png',
  ];

  late final LobbyController _controller = Get.find<LobbyController>();
  late final LobbyPreview? _preview = widget.preview ?? _controller.preview;
  Timer? _copiedReset;
  bool _copied = false;

  LobbySetup? _setup(RoomModel? room) {
    if (room == null) return _preview?.setup;
    return LobbySetup(
      categories: room.configuration.categories,
      durationSeconds: room.configuration.durationSeconds,
      rounds: room.configuration.roundCount,
      allowHardLetters: room.configuration.allowHardLetters,
      randomCategories: room.configuration.categoryMode == 'random',
    );
  }

  List<_LobbyPlayer> _players(RoomModel room) {
    var guestIndex = 0;
    return [
      for (final p in room.players)
        if (p.nickname == _controller.nickname)
          _LobbyPlayer(
            id: p.id,
            name: p.nickname,
            avatar: 'assets/images/avatar_toi.png',
            host: p.isHost,
            me: true,
          )
        else
          _LobbyPlayer(
            id: p.id,
            name: p.nickname,
            avatar: _guestAvatars[guestIndex++ % _guestAvatars.length],
            host: p.isHost,
          ),
    ];
  }

  @override
  void dispose() {
    _copiedReset?.cancel();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _controller.code));
    if (!mounted) return;
    // Le bouton affiche « COPIÉ ! » pendant deux secondes.
    setState(() => _copied = true);
    _copiedReset?.cancel();
    _copiedReset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  String _durationLabel(int seconds) =>
      seconds == 0 ? 'sans chrono' : '$seconds s';

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 300,
      child: Obx(() {
        final room = _controller.room.value;
        final setup = _setup(room);
        final isHost = _controller.isHost;
        final players = room == null ? const <_LobbyPlayer>[] : _players(room);
        final count = players.length;
        final starting = _controller.isStarting.value;
        final canStart =
            isHost &&
            room?.status == 'waiting' &&
            count >= _minPlayers &&
            !starting;
        // Toujours au moins une place libre visible ; quatre quand on est seul.
        final emptySlots = room == null
            ? 0
            : min(_maxPlayers - count, max(1, 5 - count));

        final String buttonLabel;
        if (starting) {
          buttonLabel = 'Démarrage…';
        } else if (!isHost) {
          buttonLabel = 'En attente de l’hôte…';
        } else if (room == null) {
          buttonLabel = 'Chargement du salon…';
        } else if (room.status == 'in_progress') {
          buttonLabel = 'Partie en cours…';
        } else {
          buttonLabel = 'Démarrer · $count joueur${count > 1 ? 's' : ''}';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            ScreenTitle('Salon', onBack: _controller.leaveRoom),
            const SizedBox(height: 8),
            const FieldLabel('Code d’invitation'),
            const SizedBox(height: 8),
            _CodePanel(
              code: _controller.code,
              copied: _copied,
              onCopy: _copyCode,
            ),
            const SizedBox(height: 12),
            if (setup != null) ...[
              Row(
                children: [
                  Flexible(
                    child: InfoPill(
                      'Catégories : '
                      '${setup.randomCategories ? 'Aléatoire' : 'Personnalisé'}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                  Text(
                    '${setup.rounds} manche${setup.rounds > 1 ? 's' : ''} · '
                    '${_durationLabel(setup.durationSeconds)}',
                    style: const TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 11,
                      color: AppColors.blueGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final c in setup.categories) CategoryChip(c)],
              ),
              const SizedBox(height: 14),
            ],
            FieldLabel(
              room == null
                  ? 'Joueurs · connexion au salon…'
                  : 'Joueurs $count/$_maxPlayers · '
                        '$_minPlayers à $_maxPlayers',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: room == null
                  ? Center(
                      child: _controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : Text(
                              _controller.error.value ?? 'Salon indisponible.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: AppTheme.bodyFont,
                                color: AppColors.coral,
                              ),
                            ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final p in players)
                          Padding(
                            key: ValueKey(p.id),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _PlayerRow(player: p),
                          ),
                        for (var i = 0; i < emptySlots; i++)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: _EmptySlotRow(),
                          ),
                      ],
                    ),
            ),
            if (isHost && room != null && count < _minPlayers) ...[
              const SizedBox(height: 6),
              const Text(
                'En attente des invités…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '$_minPlayers joueurs minimum pour démarrer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  color: AppColors.blueGray,
                ),
              ),
            ],
            // Erreur d'actualisation alors que le salon est déjà affiché.
            if (room != null && _controller.error.value != null) ...[
              const SizedBox(height: 6),
              Text(
                _controller.error.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  color: AppColors.coral,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ArcadeButton(
              label: buttonLabel,
              fontSize: 25,
              onPressed: canStart ? _controller.startGame : null,
            ),
          ],
        );
      }),
    );
  }
}

/// Joueur tel qu'affiché dans le salon.
class _LobbyPlayer {
  const _LobbyPlayer({
    required this.id,
    required this.name,
    required this.avatar,
    this.host = false,
    this.me = false,
  });

  final int id;
  final String name;
  final String avatar;
  final bool host;

  /// `true` : c'est l'utilisateur de cet appareil (« Toi »).
  final bool me;
}

/// Panneau du code d'invitation + bouton « COPIER ».
class _CodePanel extends StatelessWidget {
  const _CodePanel({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => DarkPanel(
    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
    child: Row(
      children: [
        Expanded(
          child: SelectableText(
            code,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: AppTheme.monoFont,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.yellow,
            ),
          ),
        ),
        Tooltip(
          message: 'Copier le code',
          child: ArcadeButton(
            label: copied ? 'Copié !' : 'Copier',
            variant: copied
                ? ArcadeButtonVariant.green
                : ArcadeButtonVariant.dark,
            small: true,
            minHeight: 40,
            onPressed: onCopy,
          ),
        ),
      ],
    ),
  );
}

/// Ligne d'un joueur : avatar cerclé, pseudo, couronne pour l'hôte.
/// Apparaît en fondu glissé quand le joueur arrive.
class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final _LobbyPlayer player;

  @override
  Widget build(BuildContext context) {
    final name =
        '${player.me ? 'Toi' : player.name}'
        '${player.host ? ' (Hôte)' : ''}';
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kGlassRowColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            PlayerAvatar(asset: player.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.offWhite,
                ),
              ),
            ),
            if (player.host)
              WordstormIcons.crown(size: 20, color: AppColors.yellow),
          ],
        ),
      ),
    );
  }
}

/// Place libre en pointillés.
class _EmptySlotRow extends StatelessWidget {
  const _EmptySlotRow();

  @override
  Widget build(BuildContext context) => DashedBox(
    color: const Color(0x40FFFFFF),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    child: Row(
      children: [
        WordstormIcons.users(size: 18, color: const Color(0x66FFFFFF)),
        const SizedBox(width: 16),
        const Text(
          'Place libre',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 13,
            color: Color(0x80FFFFFF),
          ),
        ),
      ],
    ),
  );
}
