/// Moteur de score d'une manche — Dart pur.
///
/// Terrains couverts (cahier §7, §16.1 et prompt §4) :
/// - 15 : seule réponse valide de la catégorie (bonus, aussi en solo) ;
/// - 10 : réponse valide unique (différente de toutes les autres) ;
/// - 5 : réponse identique à celle d'au moins un autre joueur ;
/// - 0 : vide ou invalide ;
/// - réutilisation (même catégorie, manche précédente) : 5 pts
///   (`ConflictPolicy.reuseWins`, provisoire) ou bonus si `bonusWins`,
///   avec badge « Règle à trancher » quand le bonus s'appliquerait.
library;

import 'rules_config.dart';
import 'validation.dart';

/// Étiquette du cas de barème appliqué (affichage des résultats).
enum ScoreTier {
  /// Vide ou invalide → 0.
  invalid,

  /// Seule réponse valide → 15 (aussi en solo).
  onlyValid,

  /// Réponse valide mais identique à celle d'un autre joueur → 5.
  shared,

  /// Réponse valide unique → 10.
  uniqueValid,

  /// Mot déjà utilisé → 5 ou bonus selon la politique de conflit.
  reused,
}

/// Ligne de score d'un joueur pour une catégorie.
class ScoreLine {
  const ScoreLine({
    required this.tier,
    required this.points,
    required this.reason,
    this.conflict = false,
    this.reused = false,
  });

  final ScoreTier tier;
  final int points;

  /// Justification en français, ex. « Seule réponse valide · bonus »
  /// ou « Ne commence pas par R ».
  final String reason;

  /// `true` : choix de règles appliqué ici est issu d'une question ouverte
  /// (badge « Règle à trancher »).
  final bool conflict;

  final bool reused;
}

/// Réponses d'un joueur pour la manche : catégorie → réponse brute.
class PlayerRoundAnswers {
  const PlayerRoundAnswers({required this.playerId, required this.answers});

  final String playerId;
  final Map<String, String> answers;
}

/// Résultat complet de la manche : joueur → catégorie → ligne de score.
class RoundScore {
  RoundScore() : _lines = {};

  final Map<String, Map<String, ScoreLine>> _lines;

  ScoreLine lineFor(String playerId, String category) =>
      _lines[playerId]?[category] ??
      const ScoreLine(
        tier: ScoreTier.invalid,
        points: 0,
        reason: 'Pas de réponse',
      );

  Iterable<String> get playerIds => _lines.keys;

  int totalFor(String playerId) =>
      _lines[playerId]!.values.fold(0, (sum, line) => sum + line.points);

  void _put(String playerId, String category, ScoreLine line) =>
      (_lines[playerId] ??= {})[category] = line;
}

/// Utilitaire de score de manche.
abstract final class RoundScoring {
  /// Vérifie puis note toutes les réponses de la manche.
  ///
  /// - [categories] : liste figée de la partie (5 à 12 catégories) ;
  /// - [letter] : lettre tirée de la manche ;
  /// - [players] : réponses brutes par joueur ;
  /// - [dictionary] : lookup optionnel (phase 3) ;
  /// - [used] : mots consommés des manches précédentes (peut être vide).
  static RoundScore scoreRound({
    required RulesConfig config,
    required String letter,
    required List<String> categories,
    required List<PlayerRoundAnswers> players,
    DictionaryLookup? dictionary,
    UsedWords? used,
  }) {
    final score = RoundScore();
    final previousWords = used ?? UsedWords();

    for (final category in categories) {
      // 1. Validation de toutes les réponses de la catégorie.
      final checks = <String, AnswerCheck>{
        for (final p in players)
          p.playerId: checkAnswer(
            category: category,
            answer: p.answers[category] ?? '',
            letter: letter,
            config: config,
            used: previousWords,
            dictionary: dictionary,
          ),
      };

      // 2. Regroupement des réponses valides identiques.
      final byWord = <String, List<String>>{};
      final validPlayers = <String>[];
      checks.forEach((playerId, check) {
        if (check.isValid) {
          validPlayers.add(playerId);
          byWord.putIfAbsent(check.normalized, () => []).add(playerId);
        }
      });

      // 3. Notation de chaque joueur de la catégorie.
      for (final p in players) {
        final check = checks[p.playerId]!;
        score._put(
          p.playerId,
          category,
          _lineFor(
            config: config,
            letter: letter,
            category: category,
            check: check,
            groupPlayers: byWord[check.normalized] ?? const [],
            validPlayerCount: validPlayers.length,
          ),
        );
      }
    }
    return score;
  }

  static ScoreLine _lineFor({
    required RulesConfig config,
    required String letter,
    required String category,
    required AnswerCheck check,
    required List<String> groupPlayers,
    required int validPlayerCount,
  }) {
    final n = check.normalized;

    if (n.isEmpty) {
      return ScoreLine(
        tier: ScoreTier.invalid,
        points: config.invalidPoints,
        reason: 'Pas de réponse',
      );
    }
    final problem = check.verdict.problem;
    if (problem != null) {
      return ScoreLine(
        tier: ScoreTier.invalid,
        points: config.invalidPoints,
        reason: switch (problem) {
          AnswerProblem.wrongLetter =>
            'Ne commence pas par ${letter.toUpperCase()}',
          AnswerProblem.tooShort => 'Réponse trop courte',
          AnswerProblem.notInDictionary =>
            'Absent du dictionnaire (catégorie : $category)',
          AnswerProblem.empty => 'Pas de réponse',
        },
        reused: check.reused,
      );
    }

    final shared = groupPlayers.length > 1;
    final onlyValid = validPlayerCount == 1;
    final soloBonus = config.soloMode;

    // Conflit de règles : mot réutilisé × palier bonus.
    if (check.reused && !shared && (onlyValid || soloBonus)) {
      return _reusedConflict(config);
    }

    if (check.reused) {
      // Réutilisé et identique à une autre réponse : 5 pts dans les deux
      // politiques (aucun conflit de barème).
      return ScoreLine(
        tier: ScoreTier.reused,
        points: config.reusedPoints,
        reason: 'Mot déjà utilisé · ${config.reusedPoints} points',
        reused: true,
      );
    }

    if (soloBonus || onlyValid) {
      return ScoreLine(
        tier: ScoreTier.onlyValid,
        points: config.onlyValidPoints,
        reason: 'Seule réponse valide · bonus',
      );
    }

    if (shared) {
      return ScoreLine(
        tier: ScoreTier.shared,
        points: config.sharedPoints,
        reason: 'Réponse identique · ${groupPlayers.length} joueurs',
      );
    }

    return ScoreLine(
      tier: ScoreTier.uniqueValid,
      points: config.uniqueValidPoints,
      reason: 'Réponse valide unique',
    );
  }

  static ScoreLine _reusedConflict(RulesConfig config) {
    if (config.conflictPolicy == ConflictPolicy.bonusWins) {
      // Le bonus l'emporte, mais le signalement reste (question Q1).
      return ScoreLine(
        tier: ScoreTier.reused,
        points: config.onlyValidPoints,
        reason: 'Mot déjà utilisé · bonus appliqué (règle à trancher)',
        conflict: true,
        reused: true,
      );
    }
    // reuseWins (provisoire, prompt §4) : 5 points + badge.
    return ScoreLine(
      tier: ScoreTier.reused,
      points: config.reusedPoints,
      reason:
          'Mot déjà utilisé · ${config.reusedPoints} points (règle à trancher)',
      conflict: true,
      reused: true,
    );
  }
}
