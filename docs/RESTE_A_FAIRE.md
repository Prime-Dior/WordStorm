# RESTE À FAIRE — journal des restes (impératif n°4 : pas de TODO caché)

## Phase 1 — restes volontaires
- **Écrans squelettes** (`PlaceholderScreen`) : Configuration, Rejoindre, Salon, Tirage,
  Manche, Fin de manche, Résultats, Paramètres, Règles, Historique — implémentation
  fidèle à la maquette à la **phase 4**.
- **Bouton « Quitter »** de l'accueil : sans action (l'API de fermeture d'app sera
  branchée à la phase 6 avec SystemNavigator, jamais simulée).
- **Validation « Rejoindre avec un code »** : l'écran « Salon introuvable » et la
  liaison au backend sont câblés à la phase 7 ; le champ est fonctionnel (alphabet,
  casse, 6 caractères) mais l'OK ne navigue pas encore.
- **Animations** (chute des lettres du logo, héros flottant, rayons rotatifs animés,
  pulsations) : leurs durées et courbes sont relevées dans `docs/ANALYSE.md` annexe ;
  implémentation à la **phase 8**.
- **Icônes à deux teintes** de la maquette (détails en `#1E2A44`) : le socle les rend
  monochromes (teinte unique). Le cas échéant, deux couches seront nécessaires pour
  100 % de fidélité — à évaluer à la phase 4.

## Phase 0 — restes enregistrements
- Installation du SDK Android + émulateur (étapes dans `docs/ENVIRONNEMENT.md`).
- Projet Firebase réel + `flutterfire configure` (phase 7 ; `docs/FIREBASE.md` à créer).

## Règles
Ce fichier est mis à jour à la fin de chaque phase. Rien n'est caché dans le code.
