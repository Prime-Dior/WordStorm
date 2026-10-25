/// Validation des réponses — Dart pur (portage complété de `validate` de
/// `gameLogic.js`, + dictionnaire optionnel en callback).
///
/// Aucune dépendance Flutter : le dictionnaire est injecté par la couche
/// données (phase 3) sous forme de callback.
library;

import 'normalization.dart';
import 'rules_config.dart';

/// Raison d'invalidité d'une réponse.
enum AnswerProblem {
  /// Champ vide, aucune saisie.
  empty,

  /// Ne commence pas par la lettre tirée.
  wrongLetter,

  /// Trop court (2 lettres ; Prénom : 3 lettres).
  tooShort,

  /// Absent du dictionnaire de la catégorie (seulement si une liste de
  /// mots existe pour cette catégorie — sinon validation souple).
  notInDictionary,
}

/// Verdict de validation d'une réponse.
class Verdict {
  /// Réponse acceptée.
  const Verdict.valid() : problem = null;

  /// Réponse refusée, avec la raison.
  const Verdict.invalid(this.problem);

  /// Aucune saisie (champ vide).
  const Verdict.empty() : problem = AnswerProblem.empty;

  final AnswerProblem? problem;

  bool get isValid => problem == null;
}

/// Résultat de validation d'une réponse, avec l'état « réutilisé ».
class AnswerCheck {
  const AnswerCheck({
    required this.verdict,
    required this.normalized,
    this.reused = false,
  });

  final Verdict verdict;
  final String normalized;

  /// Le mot a déjà servi, même catégorie, manche précédente.
  final bool reused;

  bool get isValid => verdict.isValid;
}

/// Ensemble des mots déjà consommés par catégorie (normalisés), alimenté
/// manche après manche. Un même mot reste autorisé dans une autre
/// catégorie (cahier §16.1).
class UsedWords {
  final Map<String, Set<String>> _byCategory = {};

  void add(String category, String normalized) {
    (_byCategory[category] ??= <String>{}).add(normalized);
  }

  bool wasUsed(String category, String normalized) =>
      _byCategory[category]?.contains(normalized) ?? false;

  Set<String> forCategory(String category) =>
      _byCategory[category] ?? const <String>{};

  /// Vide l'ensemble (nouvelle partie).
  void clear() => _byCategory.clear();
}

/// Signature du dictionnaire injecté : la catégorie possède-t-elle une
/// liste et le mot normalisé y figure-t-il ?
///
/// - retourne `true` : mot validé par le dictionnaire ;
/// - retourne `false` : mot absent du dictionnaire ;
/// - retourne `null` : catégorie sans liste → validation souple
///   (première lettre + longueur, comportement provisoire, Q2).
typedef DictionaryLookup = bool? Function(String category, String normalized);

/// Valide une réponse brute avec toute la logique applicable.
AnswerCheck checkAnswer({
  required String category,
  required String answer,
  required String letter,
  required RulesConfig config,
  UsedWords? used,
  DictionaryLookup? dictionary,
}) {
  final normalized = normalizeAnswer(answer);

  // 1. Vide → « Pas de réponse ».
  if (normalized.isEmpty) {
    return AnswerCheck(verdict: const Verdict.empty(), normalized: normalized);
  }

  // 2. Réutilisation même catégorie, manche précédente → verdict spécial
  //    (toujours valide au sens du barème, 5 pts, cf. prompt §4).
  final reused = used != null && used.wasUsed(category, normalized);

  // 3. Première lettre.
  //    Accents flétris déjà normalisés : É → E fonctionne.
  if (!startsWithLetter(normalized, letter)) {
    return AnswerCheck(
      verdict: const Verdict.invalid(AnswerProblem.wrongLetter),
      normalized: normalized,
      reused: reused,
    );
  }

  // 4. Longueur minimale (Prénom souple : 3 lettres, sans dictionnaire,
  //    comportement maquette).
  final isProper = category == 'Prénom';
  final min = isProper ? config.minProperNounLength : config.minWordLength;
  if (normalized.length < min) {
    return AnswerCheck(
      verdict: const Verdict.invalid(AnswerProblem.tooShort),
      normalized: normalized,
      reused: reused,
    );
  }

  // 5. Dictionnaire si disponible ; Prénom et catégories sans liste
  //    passent par la validation souple.
  if (!isProper && dictionary != null) {
    final lookup = dictionary(category, normalized);
    if (lookup == false) {
      return AnswerCheck(
        verdict: const Verdict.invalid(AnswerProblem.notInDictionary),
        normalized: normalized,
        reused: reused,
      );
    }
  }

  return AnswerCheck(
    verdict: const Verdict.valid(),
    normalized: normalized,
    reused: reused,
  );
}

/// Enregistre les mots consommés d'une manche dans [used] (à appeler
/// après la validation, pour les manches suivantes).
void registerRoundWords(
  UsedWords used,
  Map<String, Iterable<AnswerCheck>> byCategory,
) {
  byCategory.forEach((category, checks) {
    for (final c in checks) {
      if (c.isValid) used.add(category, c.normalized);
    }
  });
}
