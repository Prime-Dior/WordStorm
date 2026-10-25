// Parcours solo de bout en bout, exécution **headless** (`flutter test`).
//
// Identique au scénario d'`integration_test/solo_e2e_test.dart` (phase 5),
// mais via les roues du framework de test : menu → config (sans chrono,
// 1 manche) → tirage → saisie → STOP → résultats → fin de partie →
// REJOUER.
//
// Motivation : sur cette machine, `flutter drive -d chrome|edge` reste
// bloqué au service de debug DWDS (aucune fenêtre navigateur ne
// s'ouvre) — ce test couvre le même flux sans navigateur ; le test
// `integration_test` reste écrit pour un environnement disposant d'un
// navigateur ou d'un appareil (voir docs/RESTE_A_FAIRE.md).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/app/app.dart';
import 'package:wordstorm/app/providers.dart';
import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/response_row.dart';
import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/features/game/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Parcours solo : menu, config, tirage, manche, résultats, fin, rejouer',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          dictionaryProvider.overrideWithValue(AssetDictionaryRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Précharge le dictionnaire hors zone fake async (le chargement
      // d'asset + `compute` résolvent dans l'univers réel) ; LANCER
      // navigue alors au premier pump, sans attendre de chargement.
      await tester.runAsync(() => container.read(dictionaryProvider).load());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WordstormApp(),
        ),
      );

      // ── Accueil → Menu ─────────────────────────────────────────────
      await tester.tap(find.text('JOUER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Rejoindre avec un code'), findsOneWidget);

      // ── Menu → Configuration solo ──────────────────────────────────
      await tester.tap(find.text('SOLO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('NOUVELLE PARTIE'), findsOneWidget);

      // ── Config : sans chrono + 1 manche ────────────────────────────
      // La liste des puces est dans un scroll (17 catégories au-dessus),
      // on pilote le défilement pour rejoindre la durée puis les manches.
      await tester.scrollUntilVisible(
        find.text('Sans chrono'),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Sans chrono'));
      await tester.pump();

      // Manches 3 → 1 (deux appuis sur le bouton « − »).
      for (var i = 0; i < 2; i++) {
        await tester.scrollUntilVisible(
          find.byIcon(Icons.remove),
          280,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
      }

      // ── LANCER → roue (3,4 s) → manche ─────────────────────────────
      // Dans le framework de test, le temps des tickers est délivré
      // frame par frame (le delta peut être inférieur à la durée pompée) :
      // on boucle borné sur les pumps jusqu'à l'arrivée sur la manche
      // (60 × 300 ms ≈ 18 s de temps avancé, roue 3,4 s).
      await tester.tap(find.text('LANCER'));
      var pushManche = false;
      for (var i = 0; i < 60 && !pushManche; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        pushManche = find.byType(GameScreen).evaluate().isNotEmpty;
      }
      expect(pushManche, isTrue);
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(LetterTile), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));

      // ── Manche : remplir les 5 obligatoires puis STOP ──────────────
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        await tester.enterText(fields.at(i), 'Abc');
      }
      await tester.pump();

      await tester.tap(find.text('STOP'));
      await tester.pump();
      await tester.pump(); // la validation passe (sans chrono)

      // ── Résultats de manche : TERMINER (dernière manche) ───────────
      expect(find.text('TERMINER'), findsOneWidget);

      // ── Fin de partie : score + REJOUER ────────────────────────────
      await tester.tap(find.text('TERMINER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('PARTIE TERMINÉE'), findsOneWidget);

      // ── REJOUER : même config, nouvelle roue, nouvelle manche ──────
      await tester.tap(find.text('REJOUER'));
      pushManche = false;
      for (var i = 0; i < 60 && !pushManche; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        pushManche = find.byType(GameScreen).evaluate().isNotEmpty;
      }
      expect(pushManche, isTrue);
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));
    },
  );
}
