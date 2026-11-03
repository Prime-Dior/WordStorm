/// Session de jeu en cours (solo en phase 4 ; réutilisée par le connecteur
/// multi en phase 7 qui lui injectera les réponses/timing du salon).
///
/// Le contrôleur orchestre le **moteur pur** (`lib/domain`) :
/// configuration → tirage de lettre → réponses → score de manche →
/// manche suivante / partie finale. Aucune logique métier ne vit dans
/// les widgets (impératif du prompt).
library;

import 'package:get/get.dart';

import '../../data/dictionary/dictionary_repository.dart';
import '../../data/history/history_repository.dart';
import '../../domain/categories.dart';
import '../../domain/draws.dart';
import '../../domain/rules_config.dart';
import '../../domain/scoring.dart';
import '../../domain/validation.dart';

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
class SoloSessionController extends GetxController {
  SoloSessionController({
    required this._dictionaryRepository,
    required this._historyRepository,
  });

  final Rx<SoloSessionState> state = const SoloSessionState().obs;
  final DictionaryRepository _dictionaryRepository;
  final HistoryRepository _historyRepository;

  /// Lettres déjà tirées dans la partie (pas de répétition,
  /// portage `gameLogic.js` — cf. `docs/ANALYSE.md`).
  final Set<String> _usedLetters = {};

  /// Mots consommés, manche après manche.
  final UsedWords _usedWords = UsedWords();

  DictionaryRepository? _dictionary;

  RulesConfig get _config {
    final setup = state.value.setupOrDefault;
    return RulesConfig(
      allowHardLetters: setup.allowHardLetters,
      soloMode: true, // solo : toute réponse valide est un bonus
    );
  }

  DictionaryLookup get _lookup =>
      (category, word) => _dictionary?.wordSet(category)?.contains(word);

  /// Démarre une partie avec la configuration de l'écran « Nouvelle partie ».
  Future<void> start(GameSetup setup) async {
    final dictionary = _dictionaryRepository;
    await dictionary.load();
    _dictionary = dictionary;
    _usedLetters.clear();
    _usedWords.clear();
    state.value = SoloSessionState(setup: setup);
  }

  /// Rejoue avec la même configuration (mots consommés remis à zéro).
  Future<void> restart() async {
    final setup = state.value.setup;
    if (setup == null) return;
    await start(setup);
  }

  /// Tire la lettre de la manche (méthode appelée par la roue).
  /// Un seul tirage par manche : protégé tant que la lettre est active.
  /// [forced] sert uniquement aux tests du cas limite de la réutilisation
  /// (le tirage normal applique le sans-répétition du prompt §6).
  void drawLetter({String? forced}) {
    if (state.value.hasActiveTurn) return;
    final letter =
        forced ?? Draws.drawLetter(config: _config, usedLetters: _usedLetters);
    _usedLetters.add(letter);
    state.value = state.value.copyWith(
      round: state.value.round == 0 ? 1 : state.value.round,
      letter: letter,
      answeredByCategory: const {},
    );
  }

  /// Entreprend la manche suivante (la roue redessine).
  void nextRound() => state.value = state.value.copyWith(
    round: state.value.round + 1,
    letter: '',
  );

  /// Met à jour la réponse d'une catégorie.
  void setAnswer(String category, String value) {
    state.value = state.value.copyWith(
      answeredByCategory: {...state.value.answeredByCategory, category: value},
    );
  }

  /// Termine la manche : validation + score via le moteur pur, dans
  /// l'historique ; les mots consommés feed les manches suivantes.
  /// La mise à jour d'état est **synchrone** (avant le premier await) :
  /// l'écran de résultats voit la manche terminée immédiatement.
  Future<RoundResult?> endTurn() async {
    final setup = state.value.setupOrDefault;
    if (!state.value.hasActiveTurn) return null;

    final score = RoundScoring.scoreRound(
      config: _config,
      letter: state.value.letter,
      categories: setup.categories,
      players: [
        PlayerRoundAnswers(
          playerId: 'solo',
          answers: state.value.answeredByCategory,
        ),
      ],
      dictionary: _lookup,
      used: _usedWords,
    );

    // Les mots consommés de cette manche bloquent les manches suivantes.
    for (final category in setup.categories) {
      final check = checkAnswer(
        category: category,
        answer: state.value.answeredByCategory[category] ?? '',
        letter: state.value.letter,
        config: _config,
        used: _usedWords,
        dictionary: _lookup,
      );
      if (check.isValid) _usedWords.add(category, check.normalized);
    }

    final result = RoundResult(
      round: state.value.round,
      letter: state.value.letter,
      score: score,
    );
    state.value = state.value.copyWith(
      letter: '',
      roundHistory: [...state.value.roundHistory, result],
      finished: state.value.round >= setup.rounds,
    );

    // Partie terminée : enregistrement local (phase 6, cahier §5.1).
    if (state.value.finished) {
      await _recordGame(setup);
    }
    return result;
  }

  /// Sauvegarde la partie dans l'historique (dépriorité sur les règles :
  /// c'est de la persistance, pas du scoring — une erreur d'écriture ne
  /// doit pas faire planter la fin de partie).
  Future<void> _recordGame(GameSetup setup) async {
    try {
      final history = _historyRepository;
      final now = DateTime.now().toUtc();
      await history.save(
        GameRecord(
          id: '${now.millisecondsSinceEpoch}solo',
          dateIso:
              '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          mode: 'solo',
          rounds: state.value.roundHistory.length,
          totalScore: state.value.roundHistory.fold(
            0,
            (sum, r) => sum + r.score.totalFor('solo'),
          ),
          categories: [...setup.categories],
          letters: [for (final r in state.value.roundHistory) r.letter],
        ),
      );
    } catch (_) {
      // L'historique est de la persistance best-effort : à ne pas
      // documenter ailleurs, aucun relevé silencieux de règle métier.
    }
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
