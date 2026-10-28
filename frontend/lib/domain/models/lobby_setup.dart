/// Paramètres choisis dans la configuration et transmis à l'aperçu du salon.
/// Ce modèle reste indépendant de Firebase : aucun salon réel n'est créé.
class LobbySetup {
  const LobbySetup({
    required this.categories,
    required this.durationSeconds,
    required this.rounds,
    required this.allowHardLetters,
    required this.randomCategories,
  });

  final List<String> categories;
  final int durationSeconds;
  final int rounds;
  final bool allowHardLetters;
  final bool randomCategories;
}
