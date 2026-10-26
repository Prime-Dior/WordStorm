import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'icons/wordstorm_icons.dart';
import 'letter_tile.dart';

/// Ligne de catégorie de l'écran de configuration (`.ck` de la maquette) :
/// case à cocher + pastille d'icône + libellé (+ compteur optionnel).
///
/// Variantes :
/// - **verrouillée** (`.ck.lk`) : pas de case, cadenas jaune à droite — les
///   5 catégories obligatoires (Prénom, Ville, Pays, Animal, Objet) ;
/// - **en attente** (`.ck.dz`) : bordure en tirets, non cliquable.
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

  /// Couleur de la pastille ; à défaut, bleu-gris.
  final Color? iconColor;
  final bool selected;
  final bool locked;
  final bool inactive;
  final Widget? trailing;
  final VoidCallback? onToggle;

  static const double _boxSide = 24;

  @override
  Widget build(BuildContext context) {
    final Color bg = locked
        ? const Color(0x14FFFFFF)
        : inactive
        ? Colors.transparent
        : selected
        ? const Color(0x22FFFFFF)
        : const Color(0x14FFFFFF);

    final Decoration deco = inactive && !locked
        ? BoxDecoration(
            border: Border.all(color: const Color(0x40FFFFFF), width: 2),
            borderRadius: BorderRadius.circular(12),
          )
        : BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12));

    final Widget? leading = (locked || inactive)
        ? null
        : Container(
            width: _boxSide,
            height: _boxSide,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.blueGray, width: 2),
            ),
            child: selected
                ? const Icon(Icons.check, size: 17, color: AppColors.navyBlue)
                : null,
          );

    final content = <Widget>[
      ?leading,
      CategoryBadge(iconName: iconName ?? 'star', color: iconColor),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.offWhite,
          ),
        ),
      ),
      ?trailing,
      if (locked) WordstormIcons.lock(size: 19, color: AppColors.yellow),
    ];

    return Semantics(
      checked: locked ? null : selected,
      onTap: onToggle,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: deco,
          child: InkWell(
            onTap: locked || inactive ? null : onToggle,
            mouseCursor: locked || inactive
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(children: content),
            ),
          ),
        ),
      ),
    );
  }
}
