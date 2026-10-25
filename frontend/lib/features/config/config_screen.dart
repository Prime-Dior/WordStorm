import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/check_row.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../domain/categories.dart';
import '../../domain/draws.dart';
import '../../domain/rules_config.dart';
import '../game/state/solo_session.dart';
import '../lobby/lobby_setup.dart';

/// Écran « Nouvelle partie » (Figma 03/08) :
/// - mode de catégories **Aléatoire** (socle + 4, non
///   modifiable par l'hôte) ou **Personnalisé** (coche, max 12) ;
/// - 5 obligatoires cadenassées (Prénom, Ville, Pays, Animal, Objet) ;
/// - durée [20·Speed, 30, 45, 60, 90, 120, ∞], manches 1–5, lettres
///   difficiles (K W X Y Z) ;
/// - CTA final : LANCER (solo) · CRÉER LE SALON (multijoueur).
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key, required this.mode});

  /// 'solo' ou 'multi' (query param du routeur).
  final String mode;

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  bool _randomMode = false;
  bool _hardLetters = false;
  int _duration = 60;
  int _rounds = 3;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    for (final m in Categories.mandatory) {
      _selected.add(m);
    }
  }

  bool get _isSolo => widget.mode == 'solo';

  bool get _canStart =>
      _randomMode || Categories.isValidSelection(_selected.toList());

  void _toggle(String name) {
    if (_randomMode) return; // aléatoire non modifiable (prompt §4)
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name); // les obligatoires restent cadenassées
      } else if (_selected.length < Categories.maxPerGame) {
        _selected.add(name);
      }
    });
  }

  Future<void> _launchSolo() async {
    final setup = GameSetup(
      categories: _randomMode
          ? Draws.pickRandomCategories()
          : _selected.toList(),
      durationSeconds: _duration,
      rounds: _rounds,
      allowHardLetters: _hardLetters,
    );
    await ref.read(soloSessionProvider.notifier).start(setup);
    if (mounted) context.push('/wheel');
  }

  void _previewLobby() {
    final categories = List<String>.unmodifiable(
      _randomMode ? Draws.pickRandomCategories() : _selected,
    );
    context.push(
      '/lobby',
      extra: LobbySetup(
        categories: categories,
        durationSeconds: _duration,
        rounds: _rounds,
        allowHardLetters: _hardLetters,
        randomCategories: _randomMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(isSolo: _isSolo),
          const SizedBox(height: 14),
          _modeChips(),
          if (!_isSolo) ...[
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(0x20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withAlpha(0x66)),
              ),
              child: const Text(
                'Aperçu frontend : le salon ne sera pas en ligne ni accessible aux autres joueurs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.offWhite,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel('OBLIGATOIRES'),
                  ...Categories.mandatory.map(
                    (name) => CheckRow(
                      label: name,
                      iconName: categoryIconName(name),
                      selected: true,
                      locked: true,
                    ),
                  ),
                  _sectionLabel('OPTIONNELLES'),
                  ...Categories.optional.map((name) {
                    final checked = _selected.contains(name);
                    return CheckRow(
                      label: name,
                      iconName: categoryIconName(name),
                      selected: checked,
                      inactive: _randomMode,
                      onToggle: () => _toggle(name),
                    );
                  }),
                  Text(
                    _randomMode
                        ? 'Socle de 5 catégories + 4 tirées au sort — '
                              'non modifiable, liste figée au lancement.'
                        : '${_selected.length} / ${Categories.maxPerGame} '
                              'catégories',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueGray,
                    ),
                  ),
                  _sectionLabel('DURÉE'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 14,
                    children: [
                      for (final d in RulesConfig.turnDurations)
                        _DurationChip(
                          duration: d,
                          selected: _duration == d,
                          onTap: () => setState(() => _duration = d),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'MANCHES',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                          color: AppColors.blueGray,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Stepper(
                        min: RulesConfig.minRounds,
                        max: RulesConfig.maxRounds,
                        value: _rounds,
                        onChange: (v) => setState(() => _rounds = v),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ToggleRow(
                          label: 'Lettres K W X Y Z',
                          value: _hardLetters,
                          onChange: (v) => setState(() => _hardLetters = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!_canStart)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Maximum 12 catégories (obligatoires incluses).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF8A8E),
                ),
              ),
            ),
          if (_isSolo)
            ArcadeButton(
              label: 'Lancer',
              onPressed: _canStart ? _launchSolo : null,
            )
          else
            ArcadeButton(
              label: 'Créer le salon',
              variant: ArcadeButtonVariant.teal,
              onPressed: _canStart ? _previewLobby : null,
            ),
        ],
      ),
    );
  }

  Widget _modeChips() => Row(
    children: [
      _ModeChip(
        label: 'Aléatoire',
        selected: _randomMode,
        onTap: () => setState(() => _randomMode = true),
      ),
      _ModeChip(
        label: 'Personnalisé',
        selected: !_randomMode,
        onTap: () => setState(() => _randomMode = false),
      ),
    ],
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 20,
        color: AppColors.yellow,
      ),
    ),
  );
}

/// En-tête avec retour arrière (flèche) et titre.
class _Header extends StatelessWidget {
  const _Header({required this.isSolo});

  final bool isSolo;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: () => context.pop(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: RotatedBox(
            quarterTurns: 2,
            child: WordstormIcons.arrow(size: 22, color: AppColors.offWhite),
          ),
        ),
      ),
      Expanded(
        child: Text(
          isSolo ? 'NOUVELLE PARTIE' : 'MULTIJOUEUR',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 30,
            color: AppColors.offWhite,
          ),
        ),
      ),
      const SizedBox(width: 38),
    ],
  );
}

/// Puces Aléatoire / Personnalisé (maquette `.seg`).
class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.yellow : const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTheme.displayFont,
          fontSize: 18,
          color: selected ? AppColors.navyBlue : AppColors.offWhite,
        ),
      ),
    ),
  );
}

/// Puces de durée — 20 s porte la mention « · Speed » ; 0 = sans chrono (∞).
class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.duration,
    required this.selected,
    required this.onTap,
  });

  final int duration;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = duration == 0
        ? 'Sans chrono'
        : duration == 20
        ? '20 s · Speed'
        : '$duration s';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 17,
            color: selected ? AppColors.navyBlue : AppColors.offWhite,
          ),
        ),
      ),
    );
  }
}

/// Stepper de manches (1–5, borne provisoire du prompt §4).
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.min,
    required this.max,
    required this.value,
    required this.onChange,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _roundIconButton(
          icon: Icons.remove,
          onTap: value > min ? () => onChange(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value / $max',
            style: const TextStyle(
              fontFamily: AppTheme.monoFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.offWhite,
            ),
          ),
        ),
        _roundIconButton(
          icon: Icons.add,
          onTap: value < max ? () => onChange(value + 1) : null,
        ),
      ],
    ),
  );

  Widget _roundIconButton({required IconData icon, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null
                ? const Color(0x0AFFFFFF)
                : const Color(0x33FFFFFF),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? AppColors.blueGray : AppColors.offWhite,
          ),
        ),
      );
}

/// Ligne interrupteur compacte (lettres difficiles).
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChange(!value),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? AppColors.teal : const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.offWhite,
            ),
          ),
        ),
      ],
    ),
  );
}
