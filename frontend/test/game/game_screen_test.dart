import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordstorm/app/app.dart';
import 'package:wordstorm/core/widgets/arcade_button.dart';
import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/response_row.dart';
import 'package:wordstorm/presentation/controllers/solo_session_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Parcours : manche → saisie → VALIDER → résultats', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WordstormApp());
    await tester.pump(const Duration(milliseconds: 500));

    final session = Get.find<SoloSessionController>();
    await tester.runAsync(
      () => session.start(
        const GameSetup(
          categories: ['Animal'],
          durationSeconds: 30,
          rounds: 1,
          allowHardLetters: false,
        ),
      ),
    );
    session.drawLetter(forced: 'R');
    Get.toNamed<void>('/game');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LetterTile), findsWidgets);
    expect(find.byType(ResponseRow), findsOneWidget);
    await tester.enterText(find.byType(ResponseRow), 'Rat');
    await tester.pump();
    await tester.tap(find.widgetWithText(ArcadeButton, 'VALIDER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('+15'), findsOneWidget);
    expect(find.text('VALIDER'), findsNothing);
    Get.reset();
  });
}
