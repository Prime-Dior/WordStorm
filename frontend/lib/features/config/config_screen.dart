import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/check_row.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/categories.dart';
import '../../domain/draws.dart';
import '../../domain/rules_config.dart';
import '../game/state/solo_session.dart';
import '../lobby/lobby_setup.dart';
import '../multiplayer/demo_room.dart';

/// Écran « Nouvelle partie » (maquettes 03, 08, 20, 21).
///
/// - Mode de jeu : **Solo** ou **Multijoueur** (onglets) ;
/// - Catégories **Aléatoire** (5 obligatoires + 4 tirées au sort au
///   lancement, non modifiable) ou **Personnalisé** (cases à cocher,
///   12 au maximum) ; les 5 obligatoires portent un cadenas ;
/// - Manches 1 à 5 (boutons − et +), temps par manche (curseur :
///   20 s Speed, 30, 45, 60, 90, 120 s, sans chrono), lettres difficiles ;
/// - Bouton final : LANCER (solo) ou CRÉER LE SALON (multijoueur).
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key, required this.mode});

  /// 'solo' ou 'multi' (paramètre de l'adresse, choisi dans le menu).
  final String mode;

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  late bool _solo = widget.mode != 'multi';
  bool _randomMode = true;
  bool _hardLetters = false;
  int _durationIndex = RulesConfig.turnDurations.indexOf(60);
  int _rounds = 3;
  final Set<String> _selected = {...Categories.mandatory};

  int get _duration => RulesConfig.turnDurations[_durationIndex];

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else if (_selected.length < Categories.maxPerGame) {
        _selected.add(name);
      }
    });
  }

  /// Catégories retenues, dans l'ordre de la liste (obligatoires d'abord).
  List<String> _chosenCategories() => _randomMode
      ? Draws.pickRandomCategories()
      : [
          ...Categories.mandatory,
          ...Categories.optional.where(_selected.contains),
        ];

  Future<void> _launch() async {
    final categories = List<String>.unmodifiable(_chosenCategories());
    if (_solo) {
      ref.read(multiplayerGameProvider.notifier).state = false;
      await ref
          .read(soloSessionProvider.notifier)
          .start(
            GameSetup(
              categories: categories,
              durationSeconds: _duration,
              rounds: _rounds,
              allowHardLetters: _hardLetters,
            ),
          );
      if (mounted) context.push('/wheel');
    } else {
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
  }

  static String durationLabel(int seconds) => switch (seconds) {
    0 => 'Sans chrono',
    20 => '20 s · Speed',
    _ => '$seconds s',
  };

  @override
  Widget build(BuildContext context) {
    final countLabel = _randomMode
        ? '${Categories.mandatory.length + Categories.randomExtras} catégories'
        : '${_selected.length} / ${Categories.maxPerGame}';

    return ScreenScaffold(
      skylineHeight: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          ScreenTitle('Nouvelle partie', onBack: () => context.pop()),
          const SizedBox(height: 8),
          const FieldLabel('Mode de jeu'),
          const SizedBox(height: 8),
          SegmentedChoice<bool>(
            options: const {true: 'Solo', false: 'Multijoueur'},
            value: _solo,
            onChanged: (v) => setState(() => _solo = v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: FieldLabel('Catégories')),
              InfoPill(countLabel),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedChoice<bool>(
            options: const {true: 'Aléatoire', false: 'Personnalisé'},
            value: _randomMode,
            onChanged: (v) => setState(() => _randomMode = v),
          ),
          const SizedBox(height: 10),

          // Liste des catégories (défile si elle dépasse).
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 6),
              children: [
                for (final name in Categories.mandatory)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: CheckRow(
                      label: name,
                      iconName: categoryIconName(name),
                      selected: true,
                      locked: true,
                    ),
                  ),
                if (_randomMode)
                  const _RandomExtrasHint()
                else
                  for (final name in Categories.optional)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: CheckRow(
                        label: name,
                        iconName: categoryIconName(name),
                        selected: _selected.contains(name),
                        onToggle: () => _toggle(name),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Manches.
          Row(
            children: [
              const Expanded(child: FieldLabel('Manches')),
              _RoundStepper(
                value: _rounds,
                min: RulesConfig.minRounds,
                max: RulesConfig.maxRounds,
                onChanged: (v) => setState(() => _rounds = v),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Temps par manche.
          Row(
            children: [
              const Expanded(child: FieldLabel('Temps')),
              Text(
                durationLabel(_duration),
                style: const TextStyle(
                  fontFamily: AppTheme.monoFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
            ],
          ),
          _DurationSlider(
            key: const Key('duration-slider'),
            count: RulesConfig.turnDurations.length,
            index: _durationIndex,
            semanticValue: durationLabel(_duration),
            onChanged: (i) => setState(() => _durationIndex = i),
          ),
          CheckOptionRow(
            label: 'Inclure les lettres difficiles (K W X Y Z)',
            value: _hardLetters,
            glass: false,
            onChanged: (v) => setState(() => _hardLetters = v),
          ),
          const SizedBox(height: 10),
          ArcadeButton(
            label: _solo ? 'Lancer' : 'Créer le salon',
            onPressed: _launch,
          ),
        ],
      ),
    );
  }
}

/// Ligne en pointillés du mode aléatoire : « + 4 catégories tirées au
/// sort au lancement ».
class _RandomExtrasHint extends StatelessWidget {
  const _RandomExtrasHint();

  @override
  Widget build(BuildContext context) => DashedBox(
    child: Row(
      children: [
        WordstormIcons.bolt(size: 20, color: AppColors.blueGray),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            '+ ${Categories.randomExtras} catégories tirées au sort au lancement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 12,
              color: AppColors.blueGray,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Sélecteur du nombre de manches : boutons jaunes − et + (maquette).
class _RoundStepper extends StatelessWidget {
  const _RoundStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  Widget _button(String label, String tooltip, VoidCallback? onPressed) =>
      SizedBox(
        width: 44,
        child: ArcadeButton(
          label: label,
          small: true,
          minHeight: 42,
          padding: EdgeInsets.zero,
          borderRadius: 12,
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _button(
        '-',
        'Une manche de moins',
        value > min ? () => onChanged(value - 1) : null,
      ),
      SizedBox(
        width: 44,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.offWhite,
          ),
        ),
      ),
      _button(
        '+',
        'Une manche de plus',
        value < max ? () => onChanged(value + 1) : null,
      ),
    ],
  );
}

/// Intention clavier « avancer / reculer d'un cran » du curseur.
class _StepIntent extends Intent {
  const _StepIntent(this.delta);

  final int delta;
}

/// Curseur du temps par manche (piste dégradée turquoise → jaune,
/// bouton jaune). Crans fixes ; souris, doigt ou flèches du clavier.
/// Survol : le bouton grossit ; focus clavier : le bouton est cerclé
/// de blanc.
class _DurationSlider extends StatefulWidget {
  const _DurationSlider({
    required this.count,
    super.key,
    required this.index,
    required this.semanticValue,
    required this.onChanged,
  });

  final int count;
  final int index;
  final String semanticValue;
  final ValueChanged<int> onChanged;

  @override
  State<_DurationSlider> createState() => _DurationSliderState();
}

class _DurationSliderState extends State<_DurationSlider> {
  static const double _pad = 12;
  bool _hovered = false;
  bool _focused = false;
  bool _dragging = false;

  void _select(int i) {
    final clamped = i.clamp(0, widget.count - 1);
    if (clamped != widget.index) widget.onChanged(clamped);
  }

  void _fromPosition(double dx, double width) {
    final usable = width - 2 * _pad;
    if (usable <= 0) return;
    final t = ((dx - _pad) / usable).clamp(0.0, 1.0);
    _select((t * (widget.count - 1)).round());
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
      },
      actions: <Type, Action<Intent>>{
        _StepIntent: CallbackAction<_StepIntent>(
          onInvoke: (intent) {
            _select(widget.index + intent.delta);
            return null;
          },
        ),
      },
      child: Semantics(
        slider: true,
        label: 'Temps par manche',
        value: widget.semanticValue,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final t = widget.count <= 1
                ? 0.0
                : widget.index / (widget.count - 1);
            final knobX = _pad + t * (width - 2 * _pad);
            final big = _hovered || _dragging || _focused;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _fromPosition(d.localPosition.dx, width),
              onHorizontalDragStart: (d) {
                setState(() => _dragging = true);
                _fromPosition(d.localPosition.dx, width);
              },
              onHorizontalDragUpdate: (d) =>
                  _fromPosition(d.localPosition.dx, width),
              onHorizontalDragEnd: (_) => setState(() => _dragging = false),
              child: SizedBox(
                height: 34,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 13,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [AppColors.teal, AppColors.yellow],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      left: knobX - 12,
                      top: 5,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 140),
                        scale: big ? 1.18 : 1,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.yellow,
                            border: Border.all(
                              color: _focused
                                  ? AppColors.offWhite
                                  : AppColors.navyBlue,
                              width: 3,
                            ),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0x66000000),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                              if (big)
                                BoxShadow(
                                  color: AppColors.yellow.withAlpha(0x88),
                                  blurRadius: 12,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
