import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// État visuel d'un élément cliquable, transmis au `builder` de [Pressable].
@immutable
class PressState {
  const PressState({
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.enabled,
  });

  /// La souris est au-dessus de l'élément.
  final bool hovered;

  /// L'élément a le focus clavier (touche Tab).
  final bool focused;

  /// Le doigt ou le bouton de la souris est enfoncé.
  final bool pressed;

  /// L'élément réagit aux clics (`onPressed` non nul).
  final bool enabled;

  /// Survol ou focus : l'élément doit se mettre en avant.
  bool get highlighted => enabled && (hovered || focused);
}

/// Socle commun de tous les éléments cliquables de l'interface.
///
/// Il apporte les trois retours visuels demandés :
/// - **survol** (souris) : l'élément se soulève de 2 px et s'éclaircit ;
/// - **focus** (clavier, touche Tab) : un anneau clair entoure l'élément ;
/// - **appui** : l'élément s'enfonce (géré par le `builder` si besoin).
///
/// Il rend aussi l'élément activable au clavier (Entrée ou Espace) et
/// annonce un bouton aux lecteurs d'écran.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.builder,
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.selected,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.liftOnHover = true,
    this.hoverOverlay = const Color(0x1AFFFFFF),
    this.focusRingColor = AppColors.offWhite,
    this.autofocus = false,
  });

  /// Construit le contenu selon l'état (survol, focus, appui).
  final Widget Function(BuildContext context, PressState state) builder;

  /// Action au clic. `null` : élément désactivé.
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;

  /// Pour les choix exclusifs (onglets, puces) : lu par le lecteur d'écran.
  final bool? selected;

  /// Arrondi de l'anneau de focus et du voile de survol.
  final BorderRadius borderRadius;
  final bool liftOnHover;
  final Color hoverOverlay;
  final Color focusRingColor;
  final bool autofocus;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  // Entrée et Espace déclenchent ActivateIntent ou ButtonActivateIntent
  // selon la plateforme (le web utilise le second pour Entrée).
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _activate();
        return null;
      },
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) {
        _activate();
        return null;
      },
    ),
  };

  void _activate() => widget.onPressed?.call();

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final state = PressState(
      hovered: _hovered,
      focused: _focused,
      pressed: _pressed,
      enabled: enabled,
    );
    final lifted = enabled && widget.liftOnHover && _hovered && !_pressed;
    final showOverlay = enabled && _hovered && !_pressed;
    final showRing = enabled && _focused;

    Widget child = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, lifted ? -2 : 0, 0),
      foregroundDecoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: showOverlay ? widget.hoverOverlay : const Color(0x00FFFFFF),
        border: Border.all(
          color: showRing ? widget.focusRingColor : const Color(0x00FFFFFF),
          width: 2.5,
        ),
      ),
      child: widget.builder(context, state),
    );

    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: enabled ? _activate : null,
      child: child,
    );

    child = FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus,
      actions: _actions,
      mouseCursor: enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (value) {
        if (_hovered != value) setState(() => _hovered = value);
      },
      onShowFocusHighlight: (value) {
        if (_focused != value) setState(() => _focused = value);
      },
      child: child,
    );

    child = Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: child,
    );

    final tooltip = widget.tooltip;
    if (tooltip != null) {
      child = Tooltip(message: tooltip, child: child);
    }
    return child;
  }
}
