import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/app/providers.dart';
import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/data/history/history_repository.dart';
import 'package:wordstorm/features/game/state/solo_session.dart';

/// Contrôleur de session testé avec le **vrai dictionnaire embarqué**
/// (asset réel chargé dans l'environnement de test) et le **vrai moteur**.
/// Les lettres passées à `drawLetter(forced:)` servent à tester
/// des scénarios précis (le tirage réel lui-même est couvert par
/// `test/domain/draws_test.dart`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        dictionaryProvider.overrideWithValue(AssetDictionaryRepository()),
        // Historique remplacé par un faux en mémoire : aucune dépendance
        // plateforme (shared_preferences) dans ce test, et on inspecte
        // l'enregistrement en fin de partie.
        historyProvider.overrideWithValue(_FakeHistoryRepository()),
      ],
    );
    addTearDown(container.dispose);
  });

  GameSetup setup({
    List<String>? categories,
    int duration = 30,
    int rounds = 2,
  }) => GameSetup(
    categories: categories ?? ['Animal'],
    durationSeconds: duration,
    rounds: rounds,
    allowHardLetters: false,
  );

  test('start configure la partie ; drawLetter prépare la manche 1', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(rounds: 1));

    expect(container.read(soloSessionProvider).round, 0);
    expect(await controller.endTurn(), isNull, reason: 'pas de lettre active');

    controller.drawLetter();
    final state = container.read(soloSessionProvider);
    expect(state.round, 1);
    expect(state.hasActiveTurn, isTrue);
  });

  test('drawLetter ne tire quune fois par manche (le tirage réel est '
      'couvert par test/domain)', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup());

    controller.drawLetter(forced: 'R');
    final firstLetter = container.read(soloSessionProvider).letter;
    expect(firstLetter, 'R');

    // Deuxième appel sur la même manche : ignoré.
    controller.drawLetter(forced: 'A');
    expect(container.read(soloSessionProvider).letter, 'R');
  });

  test('le dictionnaire réel est branché : Rat 15, Zzzorge 0', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(rounds: 1, duration: 0));

    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    final result = await controller.endTurn();
    expect(result, isNotNull);
    expect(result!.score.lineFor('solo', 'Animal').points, 15);

    // Nouvelle session pour le Z (l'asset est déjà en mémoire).
    final c2 = container.read(soloSessionProvider.notifier);
    await c2.start(setup(categories: ['Pays'], rounds: 1));
    c2.drawLetter(forced: 'Z');
    c2.setAnswer('Pays', 'Zzzorge');
    final r2 = await c2.endTurn();
    expect(r2!.score.lineFor('solo', 'Pays').points, 0);
    expect(
      r2.score.lineFor('solo', 'Pays').reason,
      'Absent du dictionnaire (catégorie : Pays)',
    );
  });

  test(
    'réutilisation inter-manches : Rat 15 puis 5 (reuseWins provisoire)',
    () async {
      final controller = container.read(soloSessionProvider.notifier);
      await controller.start(setup(categories: ['Animal']));

      controller.drawLetter(forced: 'R');
      controller.setAnswer('Animal', 'Rat');
      final first = await controller.endTurn();
      expect(first!.score.lineFor('solo', 'Animal').points, 15);

      // Manche 2 : la roue tire (call nextRound avant en conditions réelles).
      controller.nextRound();
      expect(container.read(soloSessionProvider).round, 2);
      controller.drawLetter(forced: 'R'); // cas limite moteur (test only)
      controller.setAnswer('Animal', 'Rat');
      final result = await controller.endTurn();
      final line = result!.score.lineFor('solo', 'Animal');
      expect(line.points, 5);
      expect(line.reused, isTrue);
      expect(line.conflict, isTrue, reason: 'badge « Règle à trancher »');
    },
  );

  test('finished passe à true après la dernière manche', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(categories: ['Animal'], rounds: 1));
    controller.drawLetter(forced: 'R');
    await controller.endTurn();
    final state = container.read(soloSessionProvider);
    expect(state.finished, isTrue);
    expect(state.roundHistory.length, 1);
    expect(state.hasActiveTurn, isFalse);
  });

  test('controller.start réinitialise mots et lettres', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(categories: ['Animal'], rounds: 3));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    await controller.endTurn();
    controller.nextRound();
    controller.drawLetter(forced: 'A');

    await controller.restart();
    final s = container.read(soloSessionProvider);
    expect(s.round, 0);
    expect(s.letter, '');
    expect(s.roundHistory, isEmpty);
    expect(s.finished, isFalse);
  });

  test('partie terminée → enregistrée dans l\'historique', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(categories: ['Animal'], rounds: 1));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    await controller.endTurn();

    final history = container.read(historyProvider) as _FakeHistoryRepository;
    expect(history.records.length, 1);
    final saved = history.records.single;
    expect(saved.mode, 'solo');
    expect(saved.rounds, 1);
    // Rat au R = 15 (validation + scoring réels).
    expect(saved.totalScore, 15);
    expect(saved.categories, ['Animal']);
    expect(saved.letters, ['R']);
  });

  test('partie NON terminée → rien n\'est enregistré', () async {
    final controller = container.read(soloSessionProvider.notifier);
    await controller.start(setup(categories: ['Animal']));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    await controller.endTurn(); // manche 1/2 : la partie continue.

    final history = container.read(historyProvider) as _FakeHistoryRepository;
    expect(history.records, isEmpty);
  });
}

/// Dépôt en mémoire : aucune plateforme, inspectable dans les tests.
class _FakeHistoryRepository implements HistoryRepository {
  final List<GameRecord> records = [];

  @override
  Future<void> save(GameRecord record) async => records.add(record);

  @override
  Future<List<GameRecord>> all() async => [...records];

  @override
  Future<void> clear() async => records.clear();
}
