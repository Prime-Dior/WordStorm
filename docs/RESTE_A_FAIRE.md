# RESTE À FAIRE — journal des restes (impératif n°4 : pas de TODO caché)

## Phase 1 — restes volontaires
- **Écrans squelettes** (`PlaceholderScreen`) : résolu — tous les écrans
  réels sont implémentés à la phase 4 (voir `docs/PROGRESSION.md`).
- **Bouton « Quitter »** de l'accueil : résolu à la phase 6 — `SystemNavigator.pop()`.
- **Validation « Rejoindre avec un code »** : résolu côté forme (l'OK navigue
  vers l'écran Rejoindre, validation du code 6 signes sans ambigus). La
  liaison au backend et l'écran « Salon introuvable » restent câblés à la
  **phase 7**.
- **Animations** (chute des lettres du logo, héros flottant, rayons rotatifs animés,
  pulsations) : leurs durées et courbes sont relevées dans `docs/ANALYSE.md` annexe ;
  implémentation à la **phase 8**.
- **Icônes à deux teintes** de la maquette (détails en `#1E2A44`) : le socle les rend
  monochromes (teinte unique). Le cas échéant, deux couches seront nécessaires pour
  100 % de fidélité — à évaluer à la phase 4.

## Phase 6 — restes volontaires
- **Pas de classement global / réputation en ligne** : décision §5-10,
  hors périmètre sans serveur ; l'écran « classement » est l'historique
  personnel (stats locales réelles).
- **Sons synthétisés = démarrage volontairement simples** (tones sine,
  pas de samples percussifs) : habillage sonore plus riche possible à la
  phase 8 (hasard « sons générés » reconnecté à l'habillage roue).
- **Lecture sonore non exécutable dans les tests** : lecteur réel
  (audioplayers) non exécuté dans cet environnement — tests unitaires
  sur les bytes générés + gate du réglage ; à l'oreille à vérifier sur
  un vrai appareil (phase 8 ou émulateur Android).
- **Tests `integration_test` toujours non exécutés** (cf. phase 5) —
  le build **release** web, lui, est passé (`flutter build web`) :
  le blocage est propre au service de debug DWDS.
- **Historique multi** : le multi enregistrera dans le même dépôt à la
  phase 7 (`mode: 'multi'`, écran gère déjà le label Multijoueur).
- Annonce honnête des capacités : le parcours web **release** tourne
  dans Chrome via serveur statique (`build/web` + `python -m http.server`),
  le debug web reste bloqué (DWDS) — cf. `docs/ENVIRONNEMENT.md`.

## Phase 5 — restes volontaires
- **Tests `integration_test` non exécutés ici** : le fichier
  `integration_test/solo_e2e_test.dart` est écrit et prêt
  (`flutter drive --driver=test_driver/integration_test.dart
  --target=integration_test/solo_e2e_test.dart -d chrome|windows`), mais
  cet environnement n'arrive pas à y exécuter : Chrome/Edge restent
  bloqués au service de debug DWDS (aucune fenêtre ne s'ouvre), et le
  run natif Windows attend l'activation du **Mode Développeur**. Le
  même parcours est couvert par `test/app/solo_flow_e2e_test.dart`
  (headless, exécuté vert) — sur une machine disposant du navigateur,
  lancer le test d'intégration pour la vérification temps réel.
- **Le parcours e2e headless avance le temps par pumps** (motif
  documenté dans le test) : le delta avancé peut être inférieur à la
  durée pompée — à considérer si d'autres tests sont écrits sur les
  animations.
- **Salon multijoueur** (créer/rejoindre temps réel) : phase 7 — les
  écrans affichent l'état honnête « phase 7 ».

## Phase 4 — restes volontaires
- **Animations** : roue (habillage complet — pointeur pivot, anneau central,
  tick sonore à l'arrêt), pulsation/bip de chrono en fin de temps, chute des
  lettres du logo — implémentation à la **phase 8** (durations/courbes déjà
  relevées dans `docs/ANALYSE.md` annexe).
- **Sons et vibrations** : interrompus dans l'UI (réglages persistés), la
  lecture réelle est câblée à la phase 8 avec le service audio.
- **Écran de roue** : la lettre affichée au centre pendant la rotation est
  celle tirée ; un effet de « roue qui tourne vraiment derrière le disque »
  (défilement de la lettre sous le pointeur) est lissé à la phase 8.
- **Rejoindre / Salon** : validation de forme seule ; la recherche réelle du
  code (écran « Salon introuvable », reconnexion) est la **phase 7**.
- **Enregistrement des scores** (historique) : phase 6.
- **Palier 10 en solo** : toute réponse valide vaut 15 (décision prompt §4 :
  pas d'autres joueurs, palier reste multijoueur). Si l'utilisateur préfère
  10 en solo aussi, changement de `RulesConfig.soloMode` — question à trancher.
- **Icônes à deux teintes** : toujours monochromes (détail `#1E2A44` de la
  maquette) — à évaluer avec les retours visuels.

## Phase 3 — restes volontaires
- **Faux positifs du mapping** : « Fruit ou légume » accepte un légume en Fruit
  (et inversement) ; « Marque » accepte des marques hors voiture. Arbitrage complet
  (duplication et tri des listes, ou enrichissement) traité avec Q2.

## Phase 2 — restes volontaires
- **Articles et pluriels** : la normalisation ne transforme pas « le/les » ni les
  pluriels (comportement du prototype conservé). À décider si l'arbitre accorde
  ces formes — tâche léxicale, à traiter avec l'enrichissement du dictionnaire (Q2).
- **Conflit réutilisation × bonus** : arbitré provisoirement par `reuseWins`
  (badge « Règle à trancher » prévu dans l'UI des résultats, phase 4).

## Phase 0 — restes enregistrements
- Installation du SDK Android + émulateur (étapes dans `docs/ENVIRONNEMENT.md`).
- Projet Firebase réel + `flutterfire configure` (phase 7 ; `docs/FIREBASE.md` à créer).

## Règles
Ce fichier est mis à jour à la fin de chaque phase. Rien n'est caché dans le code.
