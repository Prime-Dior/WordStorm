import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'icons/wordstorm_icons.dart';
import 'letter_tile.dart';
import 'pressable.dart';
import 'ui_kit.dart';

/// Ligne de catégorie de l'écran de configuration (`.ck` de la maquette) :
/// case à cocher + pastille d'icône + libellé.
///
/// Variantes :
/// - **verrouillée** (`.ck.lk`) : pas de case, cadenas jaune à droite — les
///   5 catégories obligatoires (Prénom, Ville, Pays, Animal, Objet) ;
/// - **cochable** : case jaune à gauche, survol et focus clavier actifs.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    super.key,
    this.iconName,
    this.iconColor,
    this.selected = false,
    this.locked = false,
    this.inactive = false,
    this.trailing,
    this.onToggle,
  });

  /// Libellé de la ligne (nom de la catégorie).
  final String label;

  /// Identifiant de glyphe (décor `.ci`). Défaut : étoile neutre.
  final String? iconName;

  /// Couleur de la pastille ; à défaut, couleur de la catégorie.
  final Color? iconColor;
  final bool selected;
  final bool locked;

  /// Ligne non modifiable (mode aléatoire) : sans case, atténuée.
  final bool inactive;
  final Widget? trailing;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final interactive = !locked && !inactive && onToggle != null;

    Widget content(PressState? state) {
      final highlighted = state?.highlighted ?? false;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0x33FFFFFF) : kGlassRowColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (!locked && !inactive) ...[
              YellowCheckBox(checked: selected),
              const SizedBox(width: 10),
            ],
            CategoryBadge(
              iconName: iconName ?? 'star',
              color: iconColor ?? categoryColor(label),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: inactive
                      ? AppColors.offWhite.withAlpha(0x88)
                      : AppColors.offWhite,
                ),
              ),
            ),
            ?trailing,
            if (locked) WordstormIcons.lock(size: 18, color: AppColors.yellow),
          ],
        ),
      );
    }

    if (!interactive) {
      // Catégorie obligatoire ou mode aléatoire : non modifiable.
      return Semantics(
        checked: locked || selected,
        label: locked ? '$label (obligatoire)' : label,
        child: MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: content(null),
        ),
      );
    }

    return Semantics(
      checked: selected,
      child: Pressable(
        onPressed: onToggle,
        semanticLabel: label,
        liftOnHover: false,
        hoverOverlay: const Color(0x00FFFFFF),
        borderRadius: BorderRadius.circular(12),
        builder: (context, state) => content(state),
      ),
    );
  }
}
