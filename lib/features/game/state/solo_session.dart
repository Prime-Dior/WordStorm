/// Session de jeu en cours (solo en phase 4 ; réutilisée par le connecteur
/// multi en phase 7 qui lui injectera les réponses/timing du salon).
///
/// Le contrôleur orchestre le **moteur pur** (`lib/domain`) :
/// configuration → tirage de lettre → réponses → score de manche →
/// manche suivante / partie finale. Aucune logique métier ne vit dans
/// les widgets (impératif du prompt).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/dictionary/dictionary_repository.dart';
import '../../../domain/categories.dart';
import '../../../domain/draws.dart';
import '../../../domain/rules_config.dart';
import '../../../domain/scoring.dart';
import '../../../domain/validation.dart';

/// Paramètres d'une partie issus de l'écran « Nouvelle partie ».
class GameSetup {
  const GameSetup({
    required this.categories,
    required this.durationSeconds,
    required this.rounds,
    required this.allowHardLetters,
  });

  /// Liste figée au lancement, identique pour tous (prompt §4).
  final List<String> categories;
  final int durationSeconds; // 0 = sans chrono
  final int rounds; // 1–5 (provisoire)
  final bool allowHardLetters;

  int get categoryCount => categories.length;
}

/// Manche terminée : son score complet, prêt pour l'écran de résultats.
class RoundResult {
  const RoundResult({
    required this.round,
    required this.letter,
    required this.score,
  });

  final int round;
  final String letter;
  final RoundScore score;
}

/// État immutable de la session.
class SoloSessionState {
  const SoloSessionState({
    this.setup,
    this.round = 0,
    this.letter = '',
    this.answeredByCategory = const {},
    this.roundHistory = const [],
    this.finished = false,
  });

  final GameSetup? setup;
  final int round; // 1-based ; 0 = pas de manche tirée
  final String letter;
  final Map<String, String> answeredByCategory;
  final List<RoundResult> roundHistory;
  final bool finished;

  bool get hasActiveTurn => letter.isNotEmpty;

  GameSetup get setupOrDefault =>
      setup ??
      const GameSetup(
        categories: Categories.mandatory,
        durationSeconds: 30,
        rounds: 1,
        allowHardLetters: false,
      );
}

/// Contrôleur de la session solo.
class SoloSessionController extends StateNotifier<SoloSessionState> {
  SoloSessionController(this._ref) : super(const SoloSessionState());

  final Ref _ref;

  /// Lettres déjà tirées dans la partie (pas de répétition,
  /// portage `gameLogic.js` — cf. `docs/ANALYSE.md`).
  final Set<String> _usedLetters = {};

  /// Mots consommés, manche après manche.
  final UsedWords _usedWords = UsedWords();

  DictionaryRepository? _dictionary;

  RulesConfig get _config {
    final setup = state.setupOrDefault;
    return RulesConfig(
      allowHardLetters: setup.allowHardLetters,
      soloMode: true, // solo : toute réponse valide est un bonus
    );
  }

  DictionaryLookup get _lookup =>
      (category, word) => _dictionary?.wordSet(category)?.contains(word);

  /// Démarre une partie avec la configuration de l'écran « Nouvelle partie ».
  Future<void> start(GameSetup setup) async {
    final dictionary = _ref.read(dictionaryProvider);
    await dictionary.load();
    _dictionary = dictionary;
    _usedLetters.clear();
    _usedWords.clear();
    state = SoloSessionState(setup: setup);
  }

  /// Rejoue avec la même configuration (mots consommés remis à zéro).
  Future<void> restart() async {
    final setup = state.setup;
    if (setup == null) return;
    await start(setup);
  }

  /// Tire la lettre de la manche (méthode appelée par la roue).
  /// Un seul tirage par manche : protégé tant que la lettre est active.
  /// [forced] sert uniquement aux tests du cas limite de la réutilisation
  /// (le tirage normal applique le sans-répétition du prompt §6).
  void drawLetter({String? forced}) {
    if (state.hasActiveTurn) return;
    final letter =
        forced ?? Draws.drawLetter(config: _config, usedLetters: _usedLetters);
    _usedLetters.add(letter);
    state = state.copyWith(
      round: state.round == 0 ? 1 : state.round,
      letter: letter,
      answeredByCategory: const {},
    );
  }

  /// Entreprend la manche suivante (la roue redessine).
  void nextRound() =>
      state = state.copyWith(round: state.round + 1, letter: '');

  /// Met à jour la réponse d'une catégorie.
  void setAnswer(String category, String value) {
    state = state.copyWith(
      answeredByCategory: {...state.answeredByCategory, category: value},
    );
  }

  /// Termine la manche : validation + score via le moteur pur, dans
  /// l'historique ; les mots consommés feed les manches suivantes.
  RoundResult? endTurn() {
    final setup = state.setupOrDefault;
    if (!state.hasActiveTurn) return null;

    final score = RoundScoring.scoreRound(
      config: _config,
      letter: state.letter,
      categories: setup.categories,
      players: [
        PlayerRoundAnswers(playerId: 'solo', answers: state.answeredByCategory),
      ],
      dictionary: _lookup,
      used: _usedWords,
    );

    // Les mots consommés de cette manche bloquent les manches suivantes.
    for (final category in setup.categories) {
      final check = checkAnswer(
        category: category,
        answer: state.answeredByCategory[category] ?? '',
        letter: state.letter,
        config: _config,
        used: _usedWords,
        dictionary: _lookup,
      );
      if (check.isValid) _usedWords.add(category, check.normalized);
    }

    final result = RoundResult(
      round: state.round,
      letter: state.letter,
      score: score,
    );
    state = state.copyWith(
      letter: '',
      roundHistory: [...state.roundHistory, result],
      finished: state.round >= setup.rounds,
    );
    return result;
  }
}

extension on SoloSessionState {
  SoloSessionState copyWith({
    GameSetup? setup,
    int? round,
    String? letter,
    Map<String, String>? answeredByCategory,
    List<RoundResult>? roundHistory,
    bool? finished,
  }) => SoloSessionState(
    setup: setup ?? this.setup,
    round: round ?? this.round,
    letter: letter ?? this.letter,
    answeredByCategory: answeredByCategory ?? this.answeredByCategory,
    roundHistory: roundHistory ?? this.roundHistory,
    finished: finished ?? this.finished,
  );
}
