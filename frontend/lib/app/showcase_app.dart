import 'package:flutter/material.dart';

import 'app.dart';

/// Application de présentation : tous les écrans de la maquette sont
/// accessibles (accueil, menu, configuration, salon, rejoindre, roue,
/// manche, temps écoulé, résultats, score final, podium, fenêtres
/// d'état, paramètres, règles, classement).
///
/// Sur ordinateur, l'application est centrée dans une colonne de la
/// largeur d'un téléphone, sans cadre. Le réglage « Réduire les
/// animations » est appliqué (voir [WordstormApp]).
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const WordstormApp(desktopViewport: true);
}
