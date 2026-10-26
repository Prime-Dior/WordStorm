// Parcours solo de bout en bout (phase 5 — docs/PLAN.md) :
// Menu → config (sans chrono, 1 manche) → tirage → saisie → STOP →
// résultats (sans classement) → fin de partie → REJOUER.
//
// Exécution :
// flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/solo_e2e_test.dart -d chrome
//
// Attentions d'exécution (réalité d'un run sur navigateur) :
// - les animations et minuteurs sont réels : on attend en temps réel
//   via `tester.runAsync` (la roue met 3,4 s) ;
// - le sunburst tourne 60 s : pas de `pumpAndSettle`, on pompe
//   des frames explicitement ;
// - on choisit SANS CHRONO pour ne pas dépendre d'un minuteur de
//   20–120 s ; STOP est grisé tant que les champs ne sont pas remplis.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/response_row.dart';
import 'package:wordstorm/features/game/game_screen.dart';
import 'package:wordstorm/main.dart' as app;

Future<void> waitReal(WidgetTester tester, Duration d) async {
  await tester.runAsync(() => Future<void>.delayed(d));
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Parcours solo de bout en bout', () {
    testWidgets('menu → config → tirage → manche → résultats → fin → rejouer', (
      tester,
    ) async {
      app.main();
      await tester.pump();
      await waitReal(tester, const Duration(seconds: 1));

      // ── Accueil → Menu ────────────────────────────────────────────
      await tester.tap(find.text('JOUER'));
      await waitReal(tester, const Duration(milliseconds: 800));
      expect(find.text('REJOINDRE AVEC UN CODE'), findsOneWidget);

      // ── Menu → Configuration solo ────────────────────────────────
      await tester.tap(find.text('SOLO'));
      await waitReal(tester, const Duration(milliseconds: 800));
      expect(find.text('NOUVELLE PARTIE'), findsOneWidget);

      // ── Config : sans chrono (dernier cran du curseur) + 1 manche ─
      final slider = tester.getRect(find.byKey(const Key('duration-slider')));
      await tester.tapAt(Offset(slider.right - 2, slider.center.dy));
      await waitReal(tester, const Duration(milliseconds: 300));
      expect(find.text('Sans chrono'), findsOneWidget);

      // Manches 3 → 1 (deux appuis sur « moins »).
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byTooltip('Une manche de moins'));
        await waitReal(tester, const Duration(milliseconds: 250));
      }

      // ── LANCER → roue → C'EST PARTI ──────────────────────────────
      await tester.tap(find.text('LANCER'));
      await waitReal(tester, const Duration(milliseconds: 500));
      await waitReal(tester, const Duration(seconds: 4)); // roue 3,4 s
      await tester.tap(find.text('C’EST PARTI'));
      await waitReal(tester, const Duration(milliseconds: 800));
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(LetterTile), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));

      // ── Manche : remplir les 5 obligatoires puis STOP ────────────
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        await tester.enterText(fields.at(i), 'Abc');
      }
      await waitReal(tester, const Duration(milliseconds: 300));

      await tester.tap(find.text('STOP'));
      await waitReal(tester, const Duration(seconds: 2));

      // ── Résultats de manche (dernière manche → SCORE FINAL) ──────
      expect(find.text('MANCHE 1 / 1'), findsOneWidget);
      await tester.tap(find.text('SCORE FINAL'));
      await waitReal(tester, const Duration(seconds: 1));
      expect(find.text('Ton score'), findsOneWidget);

      // ── REJOUER : même config, nouvelle roue, nouvelle manche ────
      await tester.tap(find.text('REJOUER'));
      await waitReal(tester, const Duration(milliseconds: 500));
      await waitReal(tester, const Duration(seconds: 4)); // roue 3,4 s
      await tester.tap(find.text('C’EST PARTI'));
      await waitReal(tester, const Duration(milliseconds: 800));
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(ResponseRow), findsNWidgets(5));
    });
  });
}
