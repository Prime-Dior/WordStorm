import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Tuile de lettre jaune en volume (`.tl` de la maquette) :
/// dégradé 135°, ombre pleine en bas, reflet clair en haut, texte
/// Bangers encre foncée.
class LetterTile extends StatelessWidget {
  const LetterTile({
    required this.letter,
    super.key,
    this.size,
    this.fontSize,
    this.rotation = 0,
    this.done,
  });

  final String letter;
  final double? size;
  final double? fontSize;

  /// Rotation légère (`.fx` use `--q`).
  final double rotation;
  final bool? done;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 56;
    return Semantics(
      // Les tuiles de lettre sont audibles en lecture d'écran.
      label: 'Lettre ${letter.toUpperCase()}',
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: s,
          height: s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s * 0.16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.letterTileTop,
                AppColors.letterTileMiddle,
                AppColors.letterTileBottom,
              ],
              stops: [0, 0.6, 1],
            ),
            boxShadow: [
              const BoxShadow(
                color: AppColors.yellowDark,
                offset: Offset(0, 7),
              ),
              const BoxShadow(
                color: AppColors.letterTileShadow,
                offset: Offset(5, 8),
              ),
              const BoxShadow(
                color: Color(0xB3000000),
                offset: Offset(0, 14),
                blurRadius: 16,
              ),
              const BoxShadow(color: Color(0xAAFFFFFF), offset: Offset(0, 3)),
            ],
          ),
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: fontSize ?? s * 0.52,
              color: AppColors.letterTileInk,
              shadows: const [
                Shadow(color: Color(0x99FFFFFF), offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastille circulaire colorée avec icône (`.ci` de la maquette) : le badge
/// d'icône au début des lignes de catégorie.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({required this.iconName, this.color, super.key});

  /// Identifiant du glyphe (`wordstorm_icons.dart`).
  final String iconName;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    // Pastille décorative : la lecture d'écran lit le libellé de
    // catégorie (texte à côté), pas l'identifiant de glyphe.
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color ?? AppColors.yellow,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0x4D000000), offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
        '${_iconInner(iconName)}</svg>',
        width: 19,
        height: 19,
      ),
    ),
  );

  String _iconInner(String name) => switch (name) {
    'user' => '<circle cx="12" cy="8" r="4.5"/><path d="M3.5 21c0-5 4-7.5 8.5-7.5s8.5 2.5 8.5 7.5z"/>',
    'city' => '<path d="M2 21V9h6v12zM9 21V3h7v18zM17 21v-9h5v9z"/>',
    'globe' => '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2c4 3 4 17 0 20M12 2c-4 3-4 17 0 20" fill="none" stroke="#1E2A44" stroke-width="1.5"/>',
    'paw' => '<circle cx="5" cy="11" r="2.3"/><circle cx="9.5" cy="6" r="2.3"/><circle cx="14.5" cy="6" r="2.3"/><circle cx="19" cy="11" r="2.3"/><path d="M12 11c4 0 7 4 6 7.5-.8 2.3-3 2-6 .8-3 1.2-5.2 1.5-6-.8-1-3.5 2-7.5 6-7.5z"/>',
    'box' => '<path d="M12 2l9 4.5v11L12 22 3 17.5v-11z"/><path d="M12 22V11.5M3 6.5l9 5 9-5" fill="none" stroke="#1E2A44" stroke-width="1.5"/>',
    'wave' => '<path d="M1 9c3-3 5 3 8 0s5-3 7 0 5 3 7 0v4c-2 3-5 3-7 0s-5-3-7 0-5 3-8 0zM1 17c3-3 5 3 8 0s5-3 7 0 5 3 7 0v3c-2 2-5 2-7 0s-5-3-7 0-5 3-8 0z"/>',
    'leaf' => '<path d="M20 3C9 3 4 9 4 15c0 2 .7 4 1.5 5C6 14 10 11 14 10c-3 2-6 5-7.5 10C16 21 20 14 20 3z"/>',
    'job' => '<rect x="2.5" y="7" width="19" height="13" rx="3"/><path d="M8.5 7V5a1.5 1.5 0 0 1 1.5-1.5h4A1.5 1.5 0 0 1 15.5 5v2"/>',
    'fruit' => '<path d="M12 7c-3-2.5-9-1-8 6 .8 5.5 5 9 8 7.5 3 1.5 7.2-2 8-7.5 1-7-5-8.5-8-6z"/><path d="M12 7c0-2 1-4 3.5-4.5" fill="none" stroke="currentColor" stroke-width="2"/>',
    'film' => '<rect x="2.5" y="4" width="19" height="16" rx="3"/><path d="M7 4v16M17 4v16M2.5 9h4.5M2.5 15h4.5M17 9h4.5M17 15h4.5" stroke="#1E2A44" stroke-width="1.6" fill="none"/>',
    'ball' => '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2c4 3 4 17 0 20M12 2c-4 3-4 17 0 20" fill="none" stroke="#1E2A44" stroke-width="1.5"/>',
    'note' => '<path d="M9 3v13.5a3.5 3.5 0 1 1-2-3.1V6l12-3v10.5a3.5 3.5 0 1 1-2-3.1V5z"/>',
    'book' => '<path d="M3 5c3-1 6-1 9 1v14c-3-2-6-2-9-1zM21 5c-3-1-6-1-9 1v14c3-2 6-2 9-1z"/>',
    'bolt' => '<path d="M13 1.5L4.5 14h6.5l-1.5 8.5L19.5 10H13z"/>',
    'star' => '<path d="M12 2l3 6.5 7 .8-5.2 4.8 1.5 7L12 17.5 5.7 21.1l1.5-7L2 9.3l7-.8z"/>',
    _ => '<circle cx="12" cy="12" r="10"/>',
  };
}
