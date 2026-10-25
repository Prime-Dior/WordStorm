/// Tests de `LocalHistoryRepository` (phase 6) : persistance,
/// déduplication, plafond, effacement et statistiques dérivées.
///
/// SharedPreferences est moqué via `setMockInitialValues` : le motif
/// classique pour tester la persistance hors plateforme.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordstorm/data/history/history_repository.dart';

GameRecord record({
  required String id,
  required String dateIso,
  int totalScore = 30,
  int rounds = 1,
  List<String> letters = const ['B'],
}) => GameRecord(
  id: id,
  dateIso: dateIso,
  mode: 'solo',
  rounds: rounds,
  totalScore: totalScore,
  categories: const ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
  letters: letters,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('LocalHistoryRepository', () {
    test('all() est vide au départ', () async {
      final repo = LocalHistoryRepository();
      expect(await repo.all(), isEmpty);
    });

    test('save() + all() : la partie est persistée', () async {
      final repo = LocalHistoryRepository();
      await repo.save(record(id: '1solo', dateIso: '2026-10-24T18:03'));
      expect((await repo.all()).single.id, '1solo');
      // Nouvelle instance : la donnée doit survivre (shared_preferences).
      expect((await LocalHistoryRepository().all()).single.totalScore, 30);
    });

    test('save() déduplique par identifiant', () async {
      final repo = LocalHistoryRepository();
      await repo.save(record(id: '1solo', dateIso: '2026-10-24T18:03'));
      await repo.save(record(id: '1solo', dateIso: '2026-10-24T18:05'));
      final all = await repo.all();
      expect(all.length, 1);
      expect(all.single.dateIso, '2026-10-24T18:05');
    });

    test('all() trie du plus récent au plus ancien', () async {
      final repo = LocalHistoryRepository();
      await repo.save(record(id: 'a', dateIso: '2026-10-24T10:00'));
      await repo.save(record(id: 'b', dateIso: '2026-10-25T09:00'));
      await repo.save(record(id: 'c', dateIso: '2026-10-24T20:00'));
      final ids = [for (final r in await repo.all()) r.id];
      expect(ids, ['b', 'c', 'a']);
    });

    test('cap à 100 parties : les plus anciennes sont retirées', () async {
      final repo = LocalHistoryRepository();
      for (var i = 0; i < 105; i++) {
        final day = (i % 28 + 1).toString().padLeft(2, '0');
        await repo.save(
          record(
            id: 'r$i',
            dateIso:
                '2026-09-$day'
                'T0$i:00',
          ),
        );
      }
      final all = await repo.all();
      expect(all.length, 100);
    });

    test('clear() vide tout', () async {
      final repo = LocalHistoryRepository();
      await repo.save(record(id: '1solo', dateIso: '2026-10-24T18:03'));
      await repo.clear();
      expect(await repo.all(), isEmpty);
    });

    test('GameRecord.fromJson/toJson : aller-retour complet', () {
      final r = record(id: '1solo', dateIso: '2026-10-24T18:03');
      final copy = GameRecord.fromJson(r.toJson());
      expect(copy.id, r.id);
      expect(copy.dateIso, r.dateIso);
      expect(copy.mode, r.mode);
      expect(copy.rounds, r.rounds);
      expect(copy.totalScore, r.totalScore);
      expect(copy.categories, r.categories);
      expect(copy.letters, r.letters);
    });

    test('dateLabel au format « 24/10 2026 »', () {
      final r = record(id: '1solo', dateIso: '2026-10-24T18:03');
      expect(r.dateLabel, '24/10 2026');
    });
  });

  group('statsOf', () {
    test('vide → zéros', () {
      final s = LocalHistoryRepository.statsOf(const []);
      expect(s.games, 0);
      expect(s.bestScore, 0);
      expect(s.averageScore, 0);
      expect(s.lastScore, 0);
    });

    test('best = max, moyenne arrondie sup., last = plus récent', () {
      // all() renvoie le plus récent en tête — statsOf prend ce contrat.
      final records = [
        record(id: 'recent', dateIso: '2026-10-25T09:00', totalScore: 70),
        record(id: 'old1', dateIso: '2026-10-24T18:00', totalScore: 45),
        record(id: 'old2', dateIso: '2026-10-23T08:00'),
      ];
      final s = LocalHistoryRepository.statsOf(records);
      expect(s.games, 3);
      expect(s.bestScore, 70);
      expect(s.averageScore, 49); // ceil(145 / 3) = 49
      expect(s.lastScore, 70);
    });
  });
}
