/// Catégories du jeu — source de vérité dans `lib/domain`, **Dart pur**
/// (aucun import Flutter : le moteur doit rester testable hors widgets).
///
/// Décision prioritaire (prompt §4) : 5 catégories obligatoires avec cadenas
/// (Prénom, Ville, Pays, Animal, Objet — Ville et Pays distinctes) et la
/// liste d'optionnelles du cahier §8 complétée par le prompt. La liste est
/// figée au lancement de la partie, identique pour tous.
library;

/// Spécification d'une catégorie : nom affiché + obligatoire ou non.
class CategorySpec {
  const CategorySpec(this.name, {required this.locked});

  final String name;

  /// `true` : catégorie obligatoire (cadenas, non décochable).
  final bool locked;
}

abstract final class Categories {
  /// 5 catégories obligatoires (prompt §4, prime sur le cahier §8).
  static const List<String> mandatory = [
    'Prénom',
    'Ville',
    'Pays',
    'Animal',
    'Objet',
  ];

  /// Catégories optionnelles (cases à cocher par l'hôte).
  static const List<String> optional = [
    'Fleuve',
    'Plante',
    'Métier',
    'Nourriture',
    'Film',
    'Sport',
    'Partie du corps',
    'Marque de voiture',
    'Groupe de musique',
    'Personnage de conte',
    'Matière scolaire',
    'Fruit',
    'Légume',
    'Maladie',
    'Chanson',
  ];

  static int get mandatoryCount => mandatory.length;
  static int get optionalCount => optional.length;

  /// Maximum de catégories par partie (prompt §4 — borne provisoire ;
  /// les 5 obligatoires comptent dans ce plafond).
  static const int maxPerGame = 12;

  /// Mode aléatoire (prompt §4) : socle des 5 obligatoires + 4 tirées
  /// au sort parmi les optionnelles (nombre provisoire). Total = 9 ≤ 12.
  static const int randomExtras = 4;

  /// Nombre maximum de manches par partie (prompt §4 — borne provisoire).
  static const int maxRounds = 5;

  /// La liste est-elle valide (pas de doublon, ≤ max, obligatoires présentes) ?
  static bool isValidSelection(List<String> selected) {
    if (selected.length > maxPerGame) return false;
    final seen = <String>{};
    for (final c in selected) {
      if (!seen.add(c)) return false; // doublon
      if (!mandatory.contains(c) && !optional.contains(c)) return false;
    }
    for (final m in mandatory) {
      if (!selected.contains(m)) return false;
    }
    return true;
  }
}
