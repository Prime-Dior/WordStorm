import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icônes vectorielles de Wordstorm.
///
/// Reprend **exactement** les définitions `<symbol>` de la maquette HTML
/// (`wordstorm.html`, section `<defs>`) : mêmes viewBox 24×24, mêmes tracés.
/// Aucun emoji dans l'interface : cette classe est la source unique d'icônes.
///
/// Utilisation typique (1em, couleur héritée) :
/// ```dart
/// WordstormIcons.check(size: 22, color: Colors.white)
/// ```
class WordstormIcons {
  const WordstormIcons._();

  // Tracés bruts (définitions de la maquette, sans l'enveloppe <symbol>).
  static const String _user =
      '<circle cx="12" cy="8" r="4.5"/><path d="M3.5 21c0-5 4-7.5 8.5-7.5s8.5 2.500 8.500 7.500z"/>';
  static const String _users =
      '<circle cx="9" cy="8" r="4"/><circle cx="17.500" cy="9" r="3"/><path d="M1.500 20c0-4.500 3.500-6.500 7.500-6.500s7.500 2 7.500 6.500zM16 14c4 0 6.500 1.800 6.500 5.500H18c0-2-.8-4-2-5.500z"/>';
  static const String _gear =
      '<circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="4" stroke-dasharray="3.100 3.100"/><circle cx="12" cy="12" r="6.500"/><circle cx="12" cy="12" r="2.600" fill="#1E2A44"/>';
  static const String _trophy =
      '<path d="M6 3h12v6a6 6 0 0 1-12 0z"/><path d="M6 5H2.500c0 4 1.500 6 4 6.500M18 5h3.500c0 4-1.500 6-4 6.500" fill="none" stroke="currentColor" stroke-width="2"/><rect x="10.500" y="14" width="3" height="4"/><rect x="6.500" y="18" width="11" height="3.500" rx="1"/>';
  static const String _copy =
      '<rect x="8" y="8" width="13" height="13" rx="3"/><path d="M16 5.500V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h.5" fill="none" stroke="currentColor" stroke-width="2"/>';
  static const String _crown =
      '<path d="M2.500 19L1.500 7l6 5 4.500-8 4.500 8 6-5-1 12z" stroke="#1E2A44" stroke-width="1.600" stroke-linejoin="round"/>';
  static const String _bolt =
      '<path d="M13 1.500L4.500 14h6.500l-1.500 8.500L19.500 10H13z"/>';
  static const String _check =
      '<path d="M4 12.500l5 5L20 6" fill="none" stroke="currentColor" stroke-width="3.600" stroke-linecap="round" stroke-linejoin="round"/>';
  static const String _lock =
      '<rect x="4.500" y="10.500" width="15" height="11" rx="3"/><path d="M7.500 10.500V8a4.500 4.500 0 0 1 9 0v2.500" fill="none" stroke="currentColor" stroke-width="2.400"/>';
  static const String _paw =
      '<circle cx="5" cy="11" r="2.300"/><circle cx="9.500" cy="6" r="2.300"/><circle cx="14.500" cy="6" r="2.300"/><circle cx="19" cy="11" r="2.300"/><path d="M12 11c4 0 7 4 6 7.500-.8 2.300-3 2-6 .8-3 1.200-5.200 1.500-6-.8-1-3.500 2-7.500 6-7.500z"/>';
  static const String _job =
      '<rect x="2.500" y="7" width="19" height="13" rx="3"/><path d="M8.500 7V5a1.500 1.500 0 0 1 1.500-1.500h4A1.500 1.500 0 0 1 15.500 5v2" fill="none" stroke="currentColor" stroke-width="2"/>';
  static const String _city =
      '<path d="M2 21V9h6v12zM9 21V3h7v18zM17 21v-9h5v9z"/>';
  static const String _box =
      '<path d="M12 2l9 4.500v11L12 22 3 17.500v-11z"/><path d="M12 22V11.500M3 6.500l9 5 9-5" fill="none" stroke="#1E2A44" stroke-width="1.500"/>';
  static const String _ball =
      '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2c4 3 4 17 0 20M12 2c-4 3-4 17 0 20" fill="none" stroke="#1E2A44" stroke-width="1.500"/>';
  static const String _fruit =
      '<path d="M12 7c-3-2.500-9-1-8 6 .8 5.500 5 9 8 7.500 3 1.500 7.200-2 8-7.500 1-7-5-8.500-8-6z"/><path d="M12 7c0-2 1-4 3.500-4.500" fill="none" stroke="currentColor" stroke-width="2"/>';
  static const String _warn =
      '<path d="M12 2.500L23 21H1z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/><path d="M12 9v5.500M12 17.500v.5" stroke="#1E2A44" stroke-width="2.500" stroke-linecap="round"/>';
  static const String _clock =
      '<circle cx="12" cy="13" r="9"/><path d="M12 7.500V13l3.500 2M9.500 2h5" fill="none" stroke="#1E2A44" stroke-width="2.200" stroke-linecap="round"/>';
  static const String _arrow =
      '<path d="M4 12h15M13 5l7 7-7 7" fill="none" stroke="currentColor" stroke-width="3.200" stroke-linecap="round" stroke-linejoin="round"/>';
  static const String _globe =
      '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2c4 3 4 17 0 20M12 2c-4 3-4 17 0 20" fill="none" stroke="#1E2A44" stroke-width="1.500"/>';
  static const String _wave =
      '<path d="M1 9c3-3 5 3 8 0s5-3 7 0 5 3 7 0v4c-2 3-5 3-7 0s-5-3-7 0-5 3-8 0zM1 17c3-3 5 3 8 0s5-3 7 0 5 3 7 0v3c-2 2-5 2-7 0s-5-3-7 0-5 3-8 0z"/>';
  static const String _leaf =
      '<path d="M20 3C9 3 4 9 4 15c0 2 .7 4 1.500 5C6 14 10 11 14 10c-3 2-6 5-7.500 10C16 21 20 14 20 3z"/>';
  static const String _film =
      '<rect x="2.500" y="4" width="19" height="16" rx="3"/><path d="M7 4v16M17 4v16M2.500 9h4.500M2.500 15h4.500M17 9h4.500M17 15h4.500" stroke="#1E2A44" stroke-width="1.600" fill="none"/>';
  static const String _star =
      '<path d="M12 2l3 6.500 7 .8-5.200 4.800 1.500 7L12 17.500 5.700 21.100l1.500-7L2 9.300l7-.8z"/>';
  static const String _note =
      '<path d="M9 3v13.500a3.500 3.500 0 1 1-2-3.100V6l12-3v10.500a3.500 3.500 0 1 1-2-3.100V5z"/>';
  static const String _book =
      '<path d="M3 5c3-1 6-1 9 1v14c-3-2-6-2-9-1zM21 5c-3-1-6-1-9 1v14c3-2 6-2 9-1z"/>';

  static SvgPicture glyph(
    String inner, {
    double size = 24,
    Color? color,
  }) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$inner</svg>',
    width: size,
    height: size,
    // Les icônes sont décoratives : le sens est porté par le texte
    // adjacent (accessibilité, prompt §8).
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color, BlendMode.srcIn),
  );

  /// Accès brut pour les familles dérivées (pastilles de catégorie).
  static SvgPicture raw(String inner, {double size = 24, Color? color}) =>
      glyph(inner, size: size, color: color);

  static Widget user({double size = 24, Color? color}) =>
      glyph(_user, size: size, color: color);
  static Widget users({double size = 24, Color? color}) =>
      glyph(_users, size: size, color: color);
  static Widget gear({double size = 24, Color? color}) =>
      glyph(_gear, size: size, color: color);
  static Widget trophy({double size = 24, Color? color}) =>
      glyph(_trophy, size: size, color: color);
  static Widget copy({double size = 24, Color? color}) =>
      glyph(_copy, size: size, color: color);
  static Widget crown({double size = 24, Color? color}) =>
      glyph(_crown, size: size, color: color);
  static Widget bolt({double size = 24, Color? color}) =>
      glyph(_bolt, size: size, color: color);
  static Widget check({double size = 24, Color? color}) =>
      glyph(_check, size: size, color: color);
  static Widget lock({double size = 24, Color? color}) =>
      glyph(_lock, size: size, color: color);
  static Widget paw({double size = 24, Color? color}) =>
      glyph(_paw, size: size, color: color);
  static Widget job({double size = 24, Color? color}) =>
      glyph(_job, size: size, color: color);
  static Widget city({double size = 24, Color? color}) =>
      glyph(_city, size: size, color: color);
  static Widget box({double size = 24, Color? color}) =>
      glyph(_box, size: size, color: color);
  static Widget ball({double size = 24, Color? color}) =>
      glyph(_ball, size: size, color: color);
  static Widget fruit({double size = 24, Color? color}) =>
      glyph(_fruit, size: size, color: color);
  static Widget warn({double size = 24, Color? color}) =>
      glyph(_warn, size: size, color: color);
  static Widget clock({double size = 24, Color? color}) =>
      glyph(_clock, size: size, color: color);
  static Widget arrow({double size = 24, Color? color}) =>
      glyph(_arrow, size: size, color: color);
  static Widget globe({double size = 24, Color? color}) =>
      glyph(_globe, size: size, color: color);
  static Widget wave({double size = 24, Color? color}) =>
      glyph(_wave, size: size, color: color);
  static Widget leaf({double size = 24, Color? color}) =>
      glyph(_leaf, size: size, color: color);
  static Widget film({double size = 24, Color? color}) =>
      glyph(_film, size: size, color: color);
  static Widget star({double size = 24, Color? color}) =>
      glyph(_star, size: size, color: color);
  static Widget note({double size = 24, Color? color}) =>
      glyph(_note, size: size, color: color);
  static Widget book({double size = 24, Color? color}) =>
      glyph(_book, size: size, color: color);
}

/// Identifiants d'icônes par catégorie (même table que la maquette :
/// `CATS[nom] => icône`).
String categoryIconName(String category) => switch (category) {
  'Prénom' => 'user',
  'Ville' => 'city',
  'Pays' => 'globe',
  'Animal' => 'paw',
  'Objet' => 'box',
  'Fleuve' => 'wave',
  'Plante' => 'leaf',
  'Métier' => 'job',
  'Nourriture' => 'fruit',
  'Film' => 'film',
  'Sport' => 'ball',
  'Partie du corps' => 'user',
  'Marque de voiture' => 'star',
  'Groupe de musique' => 'note',
  'Personnage de conte' => 'book',
  'Matière scolaire' => 'book',
  'Fruit' => 'fruit',
  'Légume' => 'leaf',
  'Maladie' => 'bolt',
  'Chanson' => 'note',
  _ => 'star',
};

/// Rendu d'une icône de catégorie par identifiant de glyphe.
Widget categoryIcon(String category, {double size = 24, Color? color}) =>
    WordstormIcons.raw(
      switch (categoryIconName(category)) {
        'user' => WordstormIcons._user,
        'city' => WordstormIcons._city,
        'globe' => WordstormIcons._globe,
        'paw' => WordstormIcons._paw,
        'box' => WordstormIcons._box,
        'wave' => WordstormIcons._wave,
        'leaf' => WordstormIcons._leaf,
        'job' => WordstormIcons._job,
        'fruit' => WordstormIcons._fruit,
        'film' => WordstormIcons._film,
        'ball' => WordstormIcons._ball,
        'note' => WordstormIcons._note,
        'book' => WordstormIcons._book,
        'bolt' => WordstormIcons._bolt,
        'star' => WordstormIcons._star,
        _ => WordstormIcons._star,
      },
      size: size,
      color: color,
    );
