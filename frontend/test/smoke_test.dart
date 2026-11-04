import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/app/app.dart';
import 'package:wordstorm/core/widgets/arcade_button.dart';
import 'package:wordstorm/core/widgets/wordstorm_logo.dart';

void main() {
  testWidgets('Le socle démarre : accueil + logo + bouton JOUER', (
    tester,
  ) async {
    await tester.pumpWidget(const WordstormApp());
    await tester.pump(const Duration(milliseconds: 600));

    // Le logo et les images décoratives de lettres sont visibles.
    expect(find.byType(WordstormLogo), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/home_letter_r.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/home_letter_e.png',
      ),
      findsOneWidget,
    );

    // Bouton arcade principal : « JOUER » majuscules.
    final playButton = tester.widget<ArcadeButton>(
      find.byWidgetPredicate(
        (w) => w is ArcadeButton && w.label.toUpperCase() == 'JOUER',
      ),
    );
    expect(playButton.onPressed, isNotNull);
  });
}
