import 'package:flutter/material.dart';

import '../skeleton/status_screen.dart';

/// Salon (Figma 04/09) — **phase 7** : les salons en ligne (Firebase
/// Auth anonyme + Firestore, temps réel, démarrage par l'hôte,
/// inactivité 20 min en sans-chrono) sont implémentés à la phase 7
/// (voir `docs/PLAN.md`). Cet écran affiche l'état honnête : rien n'est
/// simulé. Le bouton « EN SORTIR » reste fonctionnel.
class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) => const StatusScreen(
    title: 'Salons en ligne bientôt jouables',
    message:
        'Les salons multijoueur arrivent avec l\'intégration Firebase '
        '(phase 7). Le moteur de règles, le dictionnaire et le solo '
        'sont déjà en place.',
    kind: StatusKind.waiting,
    actionLabel: 'Menu',
  );
}
