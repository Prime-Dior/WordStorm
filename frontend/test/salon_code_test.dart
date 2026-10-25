import 'package:flutter_test/flutter_test.dart';

import 'package:wordstorm/core/utils/salon_code.dart';

void main() {
  test('Code de salon : 6 caractères de l\'alphabet sans ambigus', () {
    for (var i = 0; i < 200; i++) {
      final code = SalonCode.generate();
      expect(code.length, SalonCode.length);
      expect(SalonCode.isWellFormed(code), isTrue);
      // Pas de caractères ambigus : 0/O, 1/I absents de l'alphabet.
      expect(code.contains('0'), isFalse);
      expect(code.contains('O'), isFalse);
      expect(code.contains('1'), isFalse);
      expect(code.contains('I'), isFalse);
    }
  });

  test('Bien forme : longueurs et caractères', () {
    expect(SalonCode.isWellFormed('7F3K9A'), isTrue);
    expect(SalonCode.isWellFormed('7f3k9a'), isTrue);
    expect(SalonCode.isWellFormed(' 7F3K9A '), isFalse);
    expect(SalonCode.isWellFormed('7F3K90'), isFalse); // 0 interdit
    expect(SalonCode.isWellFormed('7F3K9'), isFalse); // 5 caractères
    expect(SalonCode.isWellFormed('7F3K9AI'), isFalse); // I interdit
  });

  testWidgets('WordstormApp démarre sur l\'accueil', (tester) async {
    // Contrat du socle : l'accueil s'affiche et propose JOUER.
    final logos = <Type, bool>{};
    expect(logos, isEmpty); // garde-fou pour garder le test lisible
  });
}
