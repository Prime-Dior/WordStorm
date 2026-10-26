import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/salon_code.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';
import '../game/state/solo_session.dart';
import '../multiplayer/demo_room.dart';
import 'lobby_setup.dart';

/// Rôle de l'utilisateur dans le salon.
enum LobbyRole {
  /// A créé le salon depuis « Nouvelle partie » (maquettes 23 puis 04).
  host,

  /// A rejoint le salon avec un code (maquette 09).
  guest,
}

/// Écran du salon multijoueur.
///
/// - **Hôte** : code d'invitation copiable, réglages de la partie, liste
///   des joueurs. Seul au départ (« DÉMARRER · 1 JOUEUR » grisé), puis
///   les invités de démonstration arrivent un à un et le bouton
///   s'active (« DÉMARRER · 4 JOUEURS »).
/// - **Invité** : même écran, l'hôte est un autre joueur et le bouton
///   affiche « EN ATTENTE DE L'HÔTE… ».
///
/// Les joueurs viennent de [DemoRoom] tant que le backend n'existe pas.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    super.key,
    this.setup,
    this.role = LobbyRole.host,
    this.code,
  });

  /// Réglages choisis dans « Nouvelle partie » (hôte uniquement).
  final LobbySetup? setup;
  final LobbyRole role;

  /// Code saisi pour rejoindre (invité uniquement).
  final String? code;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  late final String _code;
  late final List<DemoPlayer> _players;
  Timer? _arrivals;
  Timer? _copiedReset;
  bool _copied = false;

  bool get _isHost => widget.role == LobbyRole.host;

  LobbySetup get _setup {
    if (!_isHost) {
      return const LobbySetup(
        categories: DemoRoom.joinedRoomCategories,
        durationSeconds: 60,
        rounds: 3,
        allowHardLetters: false,
        randomCategories: true,
      );
    }
    return widget.setup ??
        const LobbySetup(
          categories: ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
          durationSeconds: 60,
          rounds: 3,
          allowHardLetters: false,
          randomCategories: false,
        );
  }

  @override
  void initState() {
    super.initState();
    if (_isHost) {
      // Le code est tiré une seule fois, à l'ouverture du salon.
      _code = SalonCode.generate(Random.secure());
      _players = [
        const DemoPlayer(
          name: 'Toi',
          avatar: 'assets/images/avatar_toi.png',
          host: true,
          me: true,
        ),
      ];
      // Démonstration : les invités arrivent l'un après l'autre.
      _arrivals = Timer.periodic(DemoRoom.arrivalDelay, (timer) {
        final next = _players.length - 1;
        if (!mounted || next >= DemoRoom.guests.length) {
          timer.cancel();
          return;
        }
        setState(() => _players.add(DemoRoom.guests[next]));
      });
    } else {
      _code = widget.code ?? DemoRoom.joinableCode;
      _players = [...DemoRoom.joinedRoomPlayers];
    }
  }

  @override
  void dispose() {
    _arrivals?.cancel();
    _copiedReset?.cancel();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    // Le bouton affiche « COPIÉ ! » pendant deux secondes.
    setState(() => _copied = true);
    _copiedReset?.cancel();
    _copiedReset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  /// L'hôte lance la partie : même enchaînement que le solo (roue,
  /// manches, résultats), terminé par le podium.
  Future<void> _start() async {
    final setup = _setup;
    _arrivals?.cancel();
    ref.read(multiplayerGameProvider.notifier).state = true;
    await ref
        .read(soloSessionProvider.notifier)
        .start(
          GameSetup(
            categories: setup.categories,
            durationSeconds: setup.durationSeconds,
            rounds: setup.rounds,
            allowHardLetters: setup.allowHardLetters,
          ),
        );
    if (mounted) context.push('/wheel');
  }

  String _durationLabel(int seconds) =>
      seconds == 0 ? 'sans chrono' : '$seconds s';

  @override
  Widget build(BuildContext context) {
    final setup = _setup;
    final count = _players.length;
    final canStart = _isHost && count >= DemoRoom.minPlayers;
    // Toujours au moins une place libre visible ; quatre quand on est seul.
    final emptySlots = max(1, 5 - count);

    final String buttonLabel;
    if (!_isHost) {
      buttonLabel = 'En attente de l’hôte…';
    } else {
      buttonLabel = 'Démarrer · $count joueur${count > 1 ? 's' : ''}';
    }

    return ScreenScaffold(
      skylineHeight: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          ScreenTitle('Salon', onBack: () => context.pop()),
          const SizedBox(height: 8),
          const FieldLabel('Code d’invitation'),
          const SizedBox(height: 8),
          _CodePanel(code: _code, copied: _copied, onCopy: _copyCode),
          const SizedBox(height: 12),
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
          FieldLabel(
            'Joueurs $count/${DemoRoom.maxPlayers} · '
            '${DemoRoom.minPlayers} à ${DemoRoom.maxPlayers}',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final p in _players)
                  Padding(
                    key: ValueKey(p.name),
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
          if (_isHost && count < DemoRoom.minPlayers) ...[
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
              '${DemoRoom.minPlayers} joueurs minimum pour démarrer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 11,
                color: AppColors.blueGray,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ArcadeButton(
            label: buttonLabel,
            fontSize: 25,
            onPressed: canStart ? _start : null,
          ),
        ],
      ),
    );
  }
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
        ArcadeButton(
          label: copied ? 'Copié !' : 'Copier',
          variant: copied
              ? ArcadeButtonVariant.green
              : ArcadeButtonVariant.dark,
          small: true,
          minHeight: 40,
          tooltip: 'Copier le code',
          leading: copied
              ? const Icon(Icons.check, size: 16, color: AppColors.navyBlue)
              : WordstormIcons.copy(size: 16, color: AppColors.offWhite),
          onPressed: onCopy,
        ),
      ],
    ),
  );
}

/// Ligne d'un joueur : avatar cerclé, pseudo, couronne pour l'hôte.
/// Apparaît en fondu glissé quand le joueur arrive.
class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final DemoPlayer player;

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
