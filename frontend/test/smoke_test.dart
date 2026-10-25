import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/app/app.dart';
import 'package:wordstorm/core/widgets/arcade_button.dart';
import 'package:wordstorm/core/widgets/letter_tile.dart';
import 'package:wordstorm/core/widgets/wordstorm_logo.dart';

void main() {
  testWidgets('Le socle démarre : accueil + logo + bouton JOUER', (
    tester,
  ) async {
    // L'app consomme des providers depuis la phase 6 (settings lu à la
    // racine) : le ProviderScope fait partie du montage de test.
    await tester.pumpWidget(const ProviderScope(child: WordstormApp()));
    await tester.pump(const Duration(milliseconds: 600));

    // Logo Wordstorm visible ; tuiles de lettres posées.
    expect(find.byType(WordstormLogo), findsOneWidget);
    expect(find.byType(LetterTile), findsNWidgets(2));

    // Bouton arcade principal : « JOUER » majuscules.
    final playButton = tester.widget<ArcadeButton>(
      find.byWidgetPredicate(
        (w) => w is ArcadeButton && w.label.toUpperCase() == 'JOUER',
      ),
    );
    expect(playButton.onPressed, isNotNull);
  });
}
