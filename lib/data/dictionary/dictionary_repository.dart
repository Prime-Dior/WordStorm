/// Contrat du dictionnaire consommé par le moteur (phase 3).
///
/// Le dictionnaire Petit Bac (2 226 mots / 18 listes, `assets/words/`)
/// couvre 8 catégories Wordstorm ; les autres n'ont **pas** de liste →
/// la validation reste « souple » (première lettre + longueur), cf.
/// `docs/QUESTIONS.md` Q2. Comportement provisoire enregistré.
library;

abstract interface class DictionaryRepository {
  /// Charge les listes (HORS main isolate de préférence — géré par
  /// l'implémentation). À appeler une fois au démarrage.
  Future<void> load();

  /// Retourne l'ensemble normalisé des mots de la catégorie Wordstorm
  /// [category], ou `null` si la catégorie n'a aucune liste
  /// (validation souple de demande).
  Set<String>? wordSet(String category);

  /// Liste normalisée des catégories disponibles dans le dictionnaire.
  Iterable<String> get availableCategories;
}

/// Mapping catégories Wordstorm → listes du dictionnaire Petit Bac.
///
/// Décisions (voir `docs/ANALYSE.md` §4, comportements provisoires) :
/// - Fruit / Légume ← « Fruit ou légume » (listes mélangées : risque de
///   faux positifs dans chaque sens — arbitrage à trancher avec Q2) ;
/// - Marque de voiture ← « Marque » (contient des marques hors voiture) ;
/// - Groupe de musique ← « Chanteur ou groupe » (couverture partielle) ;
/// - les 8 catégories sans liste retournent `null` (validation souple).
const Map<String, String?> kCategoryToDictionary = {
  'Prénom': 'Prénom',
  'Ville': 'Ville',
  'Pays': 'Pays',
  'Animal': 'Animal',
  'Objet': 'Objet',
  'Métier': 'Métier',
  'Sport': 'Sport',
  'Partie du corps': 'Partie du corps',
  'Fruit': 'Fruit ou légume',
  'Légume': 'Fruit ou légume',
  'Marque de voiture': 'Marque',
  'Groupe de musique': 'Chanteur ou groupe',
  // Catégories sans liste dans le dictionnaire Petit Bac (Q2) :
  'Fleuve': null,
  'Plante': null,
  'Nourriture': null,
  'Film': null,
  'Personnage de conte': null,
  'Matière scolaire': null,
  'Maladie': null,
  'Chanson': null,
};
