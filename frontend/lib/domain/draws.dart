/// Tirage de lettres et tirage aléatoire des catégories — Dart pur.
///
/// - Pool de lettres : A–Z **moins K W X Y Z** par défaut (prompt §6 ;
///   divergence maquette : la maquette exclut aussi Q — Q reste inclus).
/// - Une lettre ne revient pas deux fois dans la même partie
///   (portage du prototype `gameLogic.js`).
/// - Mode aléatoire : 5 obligatoires + 4 optionnelles tirées au sort,
///   sans doublon, total ≤ 12 (prompt §4).
library;

import 'dart:math';

import 'categories.dart';
import 'rules_config.dart';

abstract final class Draws {
  /// Pool par défaut : 21 lettres — tout l'alphabet moins K, W, X, Y, Z
  /// (Q inclus, divergence avec la maquette qui l'exclut aussi).
  static const String defaultPool = 'ABCDEFGHIJLMNOPQRSTUV';

  /// Tire la lettre de la manche.
  ///
  /// - [usedLetters] : lettres déjà sorties dans la partie (sans
  ///   répétition). Si tout le pool est épuisé, le pool est remis à zéro
  ///   (possible avec 5 manches et 21 lettres — jamais en pratique).
  /// - [config] : active ou non les lettres difficiles (K W X Y Z).
  static String drawLetter({
    required RulesConfig config,
    Set<String> usedLetters = const {},
    Random? random,
  }) {
    var pool = defaultPool;
    if (config.allowHardLetters) pool += RulesConfig.hardLetters.join();

    final remaining = pool
        .split('')
        .where((l) => !usedLetters.contains(l))
        .toList();

    final source = remaining.isEmpty ? pool.split('') : remaining;

    final r = random ?? Random.secure();
    return source[r.nextInt(source.length)];
  }

  /// Catégories du mode aléatoire : socle des 5 obligatoires + 4 tirées
  /// au sort parmi les optionnelles (sans doublon, total 9 ≤ 12).
  /// L'hôte ne peut pas les modifier (prompt §4).
  static List<String> pickRandomCategories({Random? random}) {
    final r = random ?? Random.secure();
    final pool = List.of(Categories.optional)..shuffle(r);
    return [...Categories.mandatory, ...pool.take(Categories.randomExtras)];
  }
}
