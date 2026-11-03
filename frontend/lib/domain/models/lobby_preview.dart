import 'lobby_setup.dart';

/// Données de l'aperçu local d'un salon, en attendant son raccordement API.
class LobbyPreview {
  const LobbyPreview({
    required this.code,
    required this.nickname,
    required this.isHost,
    this.setup,
  });

  final String code;
  final String nickname;
  final bool isHost;
  final LobbySetup? setup;
}
