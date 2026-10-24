import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wordstorm/app/providers.dart';
import 'package:wordstorm/core/widgets/arcade_button.dart';
import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/response_row.dart';
import 'package:wordstorm/data/dictionary/asset_dictionary_repository.dart';
import 'package:wordstorm/features/game/game_screen.dart';
import 'package:wordstorm/features/game/state/solo_session.dart';
import 'package:wordstorm/features/results/round_results_screen.dart';
import 'package:wordstorm/features/skeleton/status_screen.dart';

/// Parcours visuel de manche avec un état contrôlé : lance une partie
/// à 1 catégorie, le contrôleur tire la lettre, on saisit une réponse,
/// VALIDER amène aux résultats avec les points affichés.
///
/// Le moteur reste inchangé — le test vérifie l'interface (contrats
/// visuels et navigation), pas les règles (déjà couverts par
/// `test/domain/` et `test/game/solo_session_test.dart`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Parcours : manche → saisie → VALIDER → résultats', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dictionaryProvider.overrideWithValue(AssetDictionaryRepository()),
      ],
    );
    addTearDown(container.dispose);

    // Mini-routeur du test : /game et /results (avec l'écran honnête
    // d'état si une route d'aide est poussée).
    final router = GoRouter(
      initialLocation: '/game',
      routes: [
        GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
        GoRoute(
          path: '/results',
          builder: (context, state) => const RoundResultsScreen(),
        ),
        GoRoute(
          path: '/wheel',
          builder: (context, state) => const StatusScreen(
            title: 'Roue',
            message: 'Test : la roue n\'est pas la cible ici.',
          ),
        ),
        GoRoute(
          path: '/final',
          builder: (context, state) => const StatusScreen(
            title: 'Fin',
            message: 'Test : fin de partie hors périmètre du test.',
          ),
        ),
      ],
    );

    // Prépare la session avant d'afficher l'écran de manche.
    // `tester.runAsync` : le chargement du dictionnaire utilise `compute`
    // (vrai isolate), impossible dans la zone FakeAsync de testWidgets.
    final notifier = container.read(soloSessionProvider.notifier);
    await tester.runAsync(() async {
      return notifier.start(
        const GameSetup(
          categories: ['Animal'],
          durationSeconds: 30,
          rounds: 1,
          allowHardLetters: false,
        ),
      );
    });

    // La roue a tiré la lettre avant d'afficher la manche.
    notifier.drawLetter();
    expect(
      container.read(soloSessionProvider).letter,
      isNotEmpty,
      reason: 'la roue tire la lettre avant la manche',
    );

    // Lance le mini-app (pas de ProviderScope de l'app : celui du test
    // contient nos surcharges).
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // Manche affichée : lettre + ligne de saisie.
    expect(find.byType(LetterTile), findsOneWidget);
    expect(find.byType(ResponseRow), findsOneWidget);

    // Saisie d'une réponse validée si la lettre est R.
    final letter = container.read(soloSessionProvider).letter;
    final answer = letter == 'R' ? 'Rat' : 'Zzzorge';
    await tester.enterText(find.byType(ResponseRow), answer);
    await tester.pump();

    // VALIDER → écran de résultats.
    await tester.tap(find.widgetWithText(ArcadeButton, 'VALIDER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Résultats : points affichés + total.
    final expected = letter == 'R' ? 15 : 0;
    expect(find.text('+$expected'), findsOneWidget);
    expect(find.text('VALIDER'), findsNothing); // navigation OK
  });
}
