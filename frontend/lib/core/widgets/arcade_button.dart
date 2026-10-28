import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

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

/// Bouton principal du jeu.
///
/// États visuels (via [Pressable]) :
/// - **survol** : le bouton se soulève, sa tranche s'épaissit et un halo
///   de sa couleur apparaît ;
/// - **focus clavier** : anneau clair autour du bouton ;
/// - **appui** : la face descend sur sa tranche (comme `.b:active`) ;
/// - **désactivé** (`onPressed == null`) : teinte kaki grisée de la
///   maquette (« DÉMARRER · 1 JOUEUR », « EN ATTENTE DE L'HÔTE… »).
class ArcadeButton extends StatelessWidget {
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
    this.leading,
    this.tooltip,
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

  /// Icône facultative avant le libellé (ex. bouton « COPIER »).
  final Widget? leading;
  final String? tooltip;

  /// Couleurs (clair, base, tranche) de chaque variante.
  static (Color, Color, Color) faces(ArcadeButtonVariant v) => switch (v) {
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
      const Color(0xFF2FD18A),
      AppColors.validateDark,
    ),
    ArcadeButtonVariant.red => (
      const Color(0xFFFF8A8E),
      AppColors.coral,
      AppColors.coralDark,
    ),
  };

  /// Teinte kaki des boutons grisés de la maquette.
  static const (Color, Color, Color) disabledFaces = (
    Color(0xFFD9D0A6),
    Color(0xFFB3A982),
    Color(0xFF7A7254),
  );

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (light, base, deep) = enabled ? faces(variant) : disabledFaces;
    final radius = borderRadius ?? (small ? 12.0 : 18.0);
    final restDepth = small ? 4.0 : 6.0;
    final ink =
        textColor ??
        (!enabled ||
                variant == ArcadeButtonVariant.yellow ||
                variant == ArcadeButtonVariant.green
            ? AppColors.navyBlue
            : Colors.white);

    final button = Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      tooltip: tooltip,
      borderRadius: BorderRadius.circular(radius),
      builder: (context, state) {
        // Appui : la face descend sur la tranche (`.b:active`).
        final depth = state.pressed
            ? 1.0
            : state.highlighted
            ? restDepth + 2
            : restDepth;
        final sink = state.pressed ? restDepth - 1 : 0.0;

        final text = Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: small ? 18 : fontSize,
            letterSpacing: 1.2,
            height: 1.1,
            color: ink,
          ),
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, sink, 0),
          // Cible tactile de confort ≥ 48 dp (accessibilité) ;
          // la maquette garde la main via `minHeight` explicite.
          constraints: BoxConstraints(minHeight: minHeight ?? 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: state.highlighted
                  ? [Color.lerp(light, Colors.white, .18)!, light]
                  : [light, base],
            ),
            boxShadow: [
              BoxShadow(color: deep, offset: Offset(0, depth)),
              const BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 12),
                blurRadius: 16,
              ),
              if (state.highlighted && enabled)
                BoxShadow(color: base.withAlpha(0x80), blurRadius: 18),
            ],
          ),
          padding:
              padding ??
              (small
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                  : const EdgeInsets.all(11)),
          // Facteurs 1 : le bouton épouse son contenu quand rien ne
          // l'étire (« FERMER »), et prend toute la largeur sinon.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: leading == null
                ? text
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      leading!,
                      const SizedBox(width: 6),
                      Flexible(child: text),
                    ],
                  ),
          ),
        );
      },
    );

    return flex > 1 ? Expanded(flex: flex, child: button) : button;
  }
}
