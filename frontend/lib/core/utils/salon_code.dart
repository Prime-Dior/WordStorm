import 'dart:math';

/// Générateur de code de salon — alphabet de la maquette, sans caractères
/// ambigus (pas de 0/O, 1/I) : `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`.
class SalonCode {
  const SalonCode._();

  static const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int length = 6;

  /// Tire un nouveau code de 6 signes.
  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    return List.generate(
      length,
      (_) => alphabet[r.nextInt(alphabet.length)],
    ).join();
  }

  /// Valide la forme d'un code saisi : exactement 6 signes de l'alphabet
  /// (la casse est ignorée, mais la valeur brute est jugée — tout
  /// caractère superflu la rend invalide).
  static String normalized(String input) => input.toUpperCase().trim();

  static bool isWellFormed(String input) {
    final v = input.toUpperCase();
    if (v.length != length) return false;
    for (final c in v.split('')) {
      if (!alphabet.contains(c)) return false;
    }
    return true;
  }
}
