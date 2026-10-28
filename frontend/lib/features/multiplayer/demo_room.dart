/// Données de démonstration du multijoueur (interfaces seulement).
///
/// Tant que le backend (Firebase, phase 7) n'existe pas, les écrans du
/// salon et du classement final s'appuient sur ces données locales.
/// **Ce fichier est le seul à remplacer** quand les salons en ligne
/// seront branchés : la liste des joueurs viendra de Firestore, le code
/// sera vérifié par le serveur et les scores calculés côté serveur.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un joueur affiché dans le salon ou sur le podium.
class DemoPlayer {
  const DemoPlayer({
    required this.name,
    required this.avatar,
    this.host = false,
    this.me = false,
  });

  final String name;
  final String avatar;
  final bool host;

  /// `true` : c'est l'utilisateur de cet appareil (« Toi »).
  final bool me;
}

abstract final class DemoRoom {
  /// Nombre maximum de joueurs dans un salon (cahier : 2 à 8).
  static const int maxPlayers = 8;

  /// Nombre minimum de joueurs pour démarrer.
  static const int minPlayers = 2;

  /// Code du salon de démonstration que l'on peut rejoindre.
  static const String joinableCode = '7F3K9A';

  static const DemoPlayer me = DemoPlayer(
    name: 'Toi',
    avatar: 'assets/images/avatar_toi.png',
    me: true,
  );

  /// Invités qui arrivent dans le salon de l'hôte, l'un après l'autre.
  static const List<DemoPlayer> guests = [
    DemoPlayer(name: 'Lina', avatar: 'assets/images/avatar_lina.png'),
    DemoPlayer(name: 'Max', avatar: 'assets/images/avatar_max.png'),
    DemoPlayer(name: 'Sami', avatar: 'assets/images/avatar_sami.png'),
  ];

  /// Délai entre deux arrivées d'invités dans le salon de l'hôte.
  static const Duration arrivalDelay = Duration(milliseconds: 1800);

  /// Salon rejoint par code (vue invité, maquette 09) : Lina est l'hôte.
  static const List<DemoPlayer> joinedRoomPlayers = [
    DemoPlayer(
      name: 'Lina',
      avatar: 'assets/images/avatar_lina.png',
      host: true,
    ),
    DemoPlayer(name: 'Max', avatar: 'assets/images/avatar_max.png'),
    DemoPlayer(name: 'Sami', avatar: 'assets/images/avatar_sami.png'),
    me,
  ];

  /// Catégories du salon rejoint (mode aléatoire, maquette 09).
  static const List<String> joinedRoomCategories = [
    'Prénom',
    'Ville',
    'Pays',
    'Animal',
    'Objet',
    'Chanson',
    'Partie du corps',
    'Fruit',
    'Matière scolaire',
  ];

  /// Scores des adversaires pour le podium (maquette 13). Le score de
  /// « Toi » est le vrai total de la partie jouée.
  static const Map<String, int> opponentScores = {
    'Lina': 255,
    'Max': 220,
    'Sami': 190,
  };
}

/// `true` quand la partie en cours a été lancée depuis un salon :
/// la fin de partie affiche alors le podium au lieu du score solo.
final multiplayerGameProvider = StateProvider<bool>((ref) => false);
