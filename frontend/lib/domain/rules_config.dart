/// Configuration des règles du moteur — Dart pur.
///
/// Chaque valeur est relevée d'une source prioritaire :
/// - barème 15/10/5/0 : cahier §7 + prompt §4 ;
/// - réutilisation = 5 points : prompt §4 (conflit tranché par [ConflictPolicy]) ;
/// - lettres difficiles K W X Y Z exclues par défaut : prompt §6 (Q inclus) ;
/// - durées de manche : maquette html (`DUR = [20,30,45,60,90,120,0]`) ;
/// - 1 à 5 manches : prompt §4 (borne provisoire).
library;

/// Politique de conflit entre « mot déjà utilisé » (5 pts) et bonus
/// (15/10 pts). Question ouverte Q1 (`docs/QUESTIONS.md`) :
/// par défaut `reuseWins` (seule valeur explicitement donnée par le prompt),
/// marquée « Règle à trancher » dans l'interface des résultats.
enum ConflictPolicy {
  /// Le mot réutilisé rapporte toujours 5, même s'il serait
  /// « seule réponse valide » (15) ou « unique » (10). Comportement provisoire.
  reuseWins,

  /// Le bonus l'emporte : un mot réutilisé qui serait la seule réponse
  /// valide vaut 15, une réponse unique vaut 10.
  bonusWins,
}

/// Barème et réglages d'une partie. Seul point de configuration du moteur :
/// toute l'UIColor passe par cet objet (prompt §5, impératif).
class RulesConfig {
  const RulesConfig({
    this.onlyValidPoints = 15,
    this.uniqueValidPoints = 10,
    this.sharedPoints = 5,
    this.invalidPoints = 0,
    this.reusedPoints = 5,
    this.conflictPolicy = ConflictPolicy.reuseWins,
    this.allowHardLetters = false,
    this.minWordLength = 2,
    this.minProperNounLength = 3,
    this.soloMode = false,
  });

  /// Seule réponse valide de la catégorie (bonus, aussi valable en solo).
  final int onlyValidPoints;

  /// Réponse valide unique (n'existe qu'en multijoueur).
  final int uniqueValidPoints;

  /// Réponse identique à celle d'au moins un autre joueur.
  final int sharedPoints;

  /// Réponse vide ou invalide.
  final int invalidPoints;

  /// Mot déjà utilisé, même catégorie, manche précédente (prompt §4 :
  /// 5 points au lieu d'un refus).
  final int reusedPoints;

  /// Arbitrage du conflit réutilisation × bonus.
  final ConflictPolicy conflictPolicy;

  /// Option « lettres difficiles » : K W X Y Z exclues du tirage tant que
  /// c'est faux (défaut). Q reste toujours disponible (prompt §6).
  final bool allowHardLetters;

  /// Longueur minimale d'une réponse (maquette : 2 lettres).
  final int minWordLength;

  /// Le Prénom bénéficie d'une règle souple : 3 lettres minimum, sans
  /// consultation du dictionnaire (comportement de la maquette).
  final int minProperNounLength;

  /// En solo, toute réponse valide est la seule → barème du bonus
  /// (prompt §4 : 15 points aussi en solo).
  final bool soloMode;

  /// Lettres difficiles (prompt §6 + prototype `letters.js`).
  static const List<String> hardLetters = ['K', 'W', 'X', 'Y', 'Z'];

  /// Durées de manche en secondes, 0 = sans chrono (maquette `DUR`).
  /// `null` modelé ici par la valeur 0.
  static const List<int> turnDurations = [20, 30, 45, 60, 90, 120, 0];

  /// Bornes de manches (1–5, prompt §4).
  static const int minRounds = 1;
  static const int maxRounds = 5;
}
