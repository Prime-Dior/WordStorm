// Parcours solo de bout en bout, exécution headless (flutter test).
//
// Menu → configuration (sans chrono, 1 manche) → tirage (C'EST PARTI) →
// saisie → STOP → résultats → score final → REJOUER.

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordstorm/app/app.dart';
import 'package:wordstorm/core/widgets/arcade_button.dart';
import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/response_row.dart';
import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/presentation/pages/game/game_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Parcours solo : menu, config, tirage, manche, résultats, fin, rejouer',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const WordstormApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() => Get.find<AssetDictionaryRepository>().load());

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

      // ── Config : catégories personnalisées (les 5 obligatoires) ────
      await tester.tap(find.text('Personnalisé'));
      await tester.pump();

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
