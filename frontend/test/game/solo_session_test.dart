import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/data/history/history_repository.dart';
import 'package:wordstorm/presentation/controllers/solo_session_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeHistoryRepository history;
  late SoloSessionController controller;

  setUp(() {
    history = _FakeHistoryRepository();
    controller = SoloSessionController(
      dictionaryRepository: AssetDictionaryRepository(),
      historyRepository: history,
    );
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
    await controller.start(setup(rounds: 1));
    expect(controller.state.value.round, 0);
    expect(await controller.endTurn(), isNull);
    controller.drawLetter();
    expect(controller.state.value.round, 1);
    expect(controller.state.value.hasActiveTurn, isTrue);
  });

  test('drawLetter ne tire qu’une fois par manche', () async {
    await controller.start(setup());
    controller.drawLetter(forced: 'R');
    controller.drawLetter(forced: 'A');
    expect(controller.state.value.letter, 'R');
  });

  test('le dictionnaire réel valide Rat et rejette Zzzorge', () async {
    await controller.start(setup(rounds: 1, duration: 0));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    final result = await controller.endTurn();
    expect(result!.score.lineFor('solo', 'Animal').points, 15);

    await controller.start(setup(categories: ['Pays'], rounds: 1));
    controller.drawLetter(forced: 'Z');
    controller.setAnswer('Pays', 'Zzzorge');
    final invalid = await controller.endTurn();
    expect(invalid!.score.lineFor('solo', 'Pays').points, 0);
  });

  test('les mots réutilisés sont signalés entre les manches', () async {
    await controller.start(setup(categories: ['Animal']));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    await controller.endTurn();
    controller.nextRound();
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    final result = await controller.endTurn();
    final line = result!.score.lineFor('solo', 'Animal');
    expect(line.points, 5);
    expect(line.reused, isTrue);
    expect(line.conflict, isTrue);
  });

  test('la partie terminée est enregistrée dans l’historique', () async {
    await controller.start(setup(rounds: 1));
    controller.drawLetter(forced: 'R');
    controller.setAnswer('Animal', 'Rat');
    await controller.endTurn();
    expect(history.records.single.totalScore, 15);
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  final records = <GameRecord>[];
  @override
  Future<void> save(GameRecord record) async => records.add(record);
  @override
  Future<List<GameRecord>> all() async => [...records];
  @override
  Future<void> clear() async => records.clear();
}
