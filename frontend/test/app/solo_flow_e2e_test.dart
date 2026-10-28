// Parcours solo de bout en bout, exécution **headless** (`flutter test`).
//
// Identique au scénario d'`integration_test/solo_e2e_test.dart` (phase 5),
// mais via les roues du framework de test : menu → config (sans chrono,
// 1 manche) → tirage (C'EST PARTI) → saisie → STOP → résultats →
// score final → REJOUER.
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
import 'package:wordstorm/core/widgets/arcade_button.dart';
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
      expect(find.text('REJOINDRE AVEC UN CODE'), findsOneWidget);

      // ── Menu → Configuration solo ──────────────────────────────────
      await tester.tap(find.text('SOLO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('NOUVELLE PARTIE'), findsOneWidget);

      // ── Config : sans chrono (dernier cran du curseur) + 1 manche ──
      final slider = tester.getRect(find.byKey(const Key('duration-slider')));
      await tester.tapAt(Offset(slider.right - 2, slider.center.dy));
      await tester.pump();
      expect(find.text('Sans chrono'), findsOneWidget);

      // Manches 3 → 1 (deux appuis sur le bouton « − »).
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byTooltip('Une manche de moins'));
        await tester.pump();
      }

      // ── LANCER → roue (3,4 s) → C'EST PARTI → manche ───────────────
      await tester.tap(find.text('LANCER'));
      await _spinWheelAndGo(tester);
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
      await tester.pump(const Duration(milliseconds: 400));

      // ── Résultats de manche (dernière manche → SCORE FINAL) ────────
      expect(find.text('MANCHE 1 / 1'), findsOneWidget);
      await tester.tap(find.widgetWithText(ArcadeButton, 'SCORE FINAL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // ── Score final : total + REJOUER ──────────────────────────────
      expect(find.text('Ton score'), findsOneWidget);
      await tester.tap(find.text('REJOUER'));
      await _spinWheelAndGo(tester);
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));
    },
  );
}

/// Attend l'arrêt de la roue (3,4 s), puis appuie sur « C'EST PARTI ».
/// Le temps des tickers avance frame par frame : boucle bornée.
Future<void> _spinWheelAndGo(WidgetTester tester) async {
  final go = find.widgetWithText(ArcadeButton, 'C’EST PARTI');
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    if (go.evaluate().isNotEmpty &&
        tester.widget<ArcadeButton>(go).onPressed != null) {
      break;
    }
  }
  expect(tester.widget<ArcadeButton>(go).onPressed, isNotNull);
  await tester.tap(go);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
