import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bouton arcade extrudé de la maquette :
/// ```css
/// .b{
///   font:400 27px Bangers;upper;border-radius:18px;color:var(--n);
///   background:linear-gradient(#FFD25A,var(--c,#FFB703));--d:#C98300;
///   box-shadow:0 6px 0 var(--d),0 12px 16px #0006,inset 0 2px 0 #fff9
/// }
/// .b:active{transform:translateY(5px);box-shadow:0 1px 0 var(--d),...}
/// .b.sm{font-size:18px;padding:8px 14px;border-radius:12px}
/// ```
/// Variantes de teinte (couple `--c`/`--d` du CSS) : jaune, teal, purple,
/// dark, green, red.
enum ArcadeButtonVariant { yellow, teal, purple, dark, green, red }

class ArcadeButton extends StatefulWidget {
  const ArcadeButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = ArcadeButtonVariant.yellow,
    this.small = false,
    this.fontSize = 27,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.flex = 1,
    this.minHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final ArcadeButtonVariant variant;
  final bool small;
  final double fontSize;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  /// Comportement de grille de la maquette
  /// (`.bt2 .b:first-child{flex:2} .b:last-child{flex:1}`).
  final int flex;
  final double? minHeight;

  @override
  State<ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<ArcadeButton> {
  bool _pressed = false;

  (Color, Color, Color) _faces(ArcadeButtonVariant v, bool enabled) {
    final (light, base, deep) = switch (v) {
      ArcadeButtonVariant.yellow => (
        AppColors.yellowLight,
        AppColors.yellow,
        AppColors.yellowDark,
      ),
      ArcadeButtonVariant.teal => (
        AppColors.tealLight,
        AppColors.teal,
        AppColors.tealDark,
      ),
      ArcadeButtonVariant.purple => (
        AppColors.purpleLight,
        AppColors.purple,
        AppColors.purpleDark,
      ),
      ArcadeButtonVariant.dark => (
        AppColors.darkButtonTop,
        AppColors.darkButton,
        AppColors.darkButtonDeep,
      ),
      ArcadeButtonVariant.green => (
        const Color(0xFF5CF0A8),
        const Color(0xFF1FBF74),
        AppColors.validateDark,
      ),
      ArcadeButtonVariant.red => (
        const Color(0xFFFF8A8E),
        AppColors.coral,
        AppColors.coralDark,
      ),
    };
    if (enabled) return (light, base, deep);
    return (base, base, base); // état grisé (`.b.dis`).
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final (light, base, deep) = _faces(widget.variant, enabled);
    final radius = widget.borderRadius ?? (widget.small ? 12.0 : 18.0);
    final depth = _pressed ? 1.0 : (widget.small ? 4.0 : 6.0);
    final contrastText =
        widget.textColor ??
        (widget.variant == ArcadeButtonVariant.yellow
            ? AppColors.navyBlue
            : Colors.white);

    final inner = Text(
      widget.label.toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: widget.small ? 18 : widget.fontSize,
        letterSpacing: 1.6,
        height: 1.1,
        color: contrastText,
      ),
    );

    final child = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: Container(
        // Cible tactile de confort ≥ 48 dp (accessibilité, phase 6) ;
        // la maquette garde la main via `minHeight` explicite.
        constraints: BoxConstraints(minHeight: widget.minHeight ?? 48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, base],
          ),
          boxShadow: [
            BoxShadow(color: deep, offset: Offset(0, depth)),
            const BoxShadow(
              color: Color(0x99000000),
              offset: Offset(0, 12),
              blurRadius: 16,
            ),
            const BoxShadow(color: Color(0x99FFFFFF), offset: Offset(0, 2)),
          ],
        ),
        padding:
            widget.padding ??
            (widget.small
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                : const EdgeInsets.all(11)),
        child: Center(child: inner),
      ),
    );

    final interactive = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: child,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: widget.flex > 1
          ? Expanded(flex: widget.flex, child: interactive)
          : interactive,
    );
  }
}
