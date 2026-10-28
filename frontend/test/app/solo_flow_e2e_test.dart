// Parcours solo de bout en bout, exécution headless (flutter test).
//
// Menu → configuration → roue → manche → résultats → fin → rejouer.

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

      // Précharger le dictionnaire avant de commencer le parcours.
      await tester.runAsync(() => container.read(dictionaryProvider).load());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WordstormApp(),
        ),
      );

      // Accueil → Menu
      await tester.tap(find.text('JOUER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Rejoindre avec un code'), findsOneWidget);

      // Menu → Configuration solo
      await tester.tap(find.text('SOLO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('NOUVELLE PARTIE'), findsOneWidget);

      // Configuration : sans chrono
      await tester.scrollUntilVisible(
        find.text('Sans chrono'),
        280,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Sans chrono'));
      await tester.pump();

      // Passer de 3 manches à 1 manche.
      for (var i = 0; i < 2; i++) {
        await tester.scrollUntilVisible(
          find.byIcon(Icons.remove),
          280,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
      }

      // LANCER → roue → manche
      await tester.tap(find.text('LANCER'));
      await tester.pump();

      var pushManche = false;

      for (var i = 0; i < 60 && !pushManche; i++) {
        await tester.pump(const Duration(milliseconds: 300));

        final startButton = find.text("C'EST PARTI");

        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton.first, warnIfMissed: false);
          await tester.pump();
        }

        pushManche = find.byType(GameScreen).evaluate().isNotEmpty;
      }

      expect(
        pushManche,
        isTrue,
        reason: 'GameScreen devrait apparaître après le tirage.',
      );

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(LetterTile), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));

      // Manche : remplir les cinq réponses obligatoires.
      final fields = find.byType(TextField);

      expect(fields, findsNWidgets(5));

      for (var i = 0; i < 5; i++) {
        await tester.enterText(fields.at(i), 'Abc');
      }

      await tester.pump();

      // STOP
      await tester.tap(find.text('STOP'));
      await tester.pump();
      await tester.pump();

      // Résultats de manche
      expect(find.text('TERMINER'), findsOneWidget);

      await tester.tap(find.text('TERMINER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Fin de partie
      expect(find.text('PARTIE TERMINÉE'), findsOneWidget);

      // REJOUER → nouvelle roue → nouvelle manche
      await tester.tap(find.text('REJOUER'));
      await tester.pump();

      pushManche = false;

      for (var i = 0; i < 60 && !pushManche; i++) {
        await tester.pump(const Duration(milliseconds: 300));

        final startButton = find.text("C'EST PARTI");

        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton.first, warnIfMissed: false);
          await tester.pump();
        }

        pushManche = find.byType(GameScreen).evaluate().isNotEmpty;
      }

      expect(
        pushManche,
        isTrue,
        reason: 'GameScreen devrait apparaître après REJOUER.',
      );

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));
    },
  );
}
