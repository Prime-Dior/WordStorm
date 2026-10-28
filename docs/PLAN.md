# PLAN — détail des phases (section 11 du prompt)

Chaque phase se termine par : `dart format .`, `flutter analyze` sans avertissement, tests verts, **commit** (Conventional Commits, anglais/f constant), mise à jour de `docs/PROGRESSION.md`.

## Phase 0 — Reconnaissance ✅
- Sources lues (prompt, cahier complet, maquette HTML + JS, Figma rastérisé, prototype Petit Bac).
- `docs/ANALYSE.md`, `docs/QUESTIONS.md`, `docs/PLAN.md` (ce fichier).
- `flutter doctor` exécuté et consigné. Contrainte : Android SDK à installer (cmdline-tools présent dans Downloads).

## Phase 1 — Socle
- Projet Flutter conservé dans `frontend/` ; la racine du dépôt garde `README.md`, `docs/`, `.github/` et le dossier réservé `backend/`.
- `pubspec.yaml` : riverpod, go_router, flutter_svg, flutter_animate (pré-évaluée), shared_preferences ; lints stricts (`flutter_lints`), formatage.
- `lib/core` : thème (palette + polices TTF conversion woff2), décor (CustomPainter : ville de jour/nuit, rayons), composants figma : `ArcadeButton`, `CategoryTile`, `ResponseRow`, `PlayerCard`, `CheckboxRow`, `LockBadge`, `CodeField`, `NavigationChip`…
- `lib/app` : routage `go_router`, squelette d'écrans non simulés.
- CI GitHub Actions (flutter analyze + test).
- **Vert** : analyse sans warning, l'app compile et se lance (web/Android si prêt).

## Phase 2 — Moteur de règles (Dart pur, `lib/domain`)
- `normalize`, `utility de filtrage saisie`, `validate` (lettre, longueur min 2 ; Prénom ≥ 3 indépendant), barème 15/10/5/0 paramétrable, `ConflictPolicy` (`reuseWins`/`bonusWins`), réutilisation inter-manches, `pickLetter` (sans lettres exclues, sans répétition), `pickRandomCategories` (max 12, sans doublon), scoring solo vs multi, exemple de référence du cahier §16.1 (Anna 35, Ben 15, Cyril 15).
- **Vert** : couverture de tests élevée sur `lib/domain`, zéro logique métier dans les widgets.

## Phase 3 — Dictionnaire + dépôts locaux
- Extraction `wordLists.js` → JSON embarqué (2 226 mots), chargé hors main isolate si lourd.
- `DictionaryRepository` (interface + impl. locale), catégories mappées ; validation par lettre+longueur pour catégories sans liste (marqué provisoire).
- `SettingsRepository` (shared_preferences) : pseudo, sons, vibrations, animations réduites.
- **Vert** : tests d'accès et de normalisation.

## Phase 4 — Écrans et navigation (fidélité maquette)
- Accueil (animation logo, héros), Menu, Rejoindre avec un code, Nouvelle partie (Solo/Multi, Aléatoire/Personnalisé, cadenas, max 12, stepper, curseur durées, lettres difficiles, LANCER/CRÉER LE SALON), Salon (hôte/invité, code copiable, temps réel), Tirage (roue), Partie (chrono, anneau, saisie, avatars d'humeur, VALIDER/STOP), Fin du temps, Résultats de manche (compteur animé, règles appliquées, badge à trancher), Résultats finaux (solo sans classement ; multi podium animé), États (attente, chargement, erreur, salon introuvable, paramètres, règles).
- Transitions cohérentes avec la maquette. Golden tests recommandés sur écrans clés.
- **Vert** : `flutter analyze` + tests widget.

## Phase 5 — Solo complet hors ligne (integration_test)
- Parcours : Menu → config → tirage → saisie → fin → résultats (sans classement) → rejouer.
- Dictionnaire branché ; réponses concurrentes simulées pas possibles en solo (règle 15 points).

## Phase 6 — Historique / paramètres / accessibilité / sons
- Historique (`HistoryRepository`), statistiques de base ; réglages (sons, vibrations, animations) ; accessibilité (Semantics, tailles, contrastes, min 48dp, réduction automatique d'animations OS).
- Sons générés (roue, démarrage, 5 dernières secondes, validation, victoire) et vibrations désactivables.

## Phase 7 — Multijoueur Laravel (raccordement en cours)
- API maintenue dans le dépôt séparé `Alecdev-10/wordstorm-api` : sessions invitées, salons, joueurs, manches, réponses, validation lexicale et scores.
- Flutter raccordé aux sessions invitées, à la création/rejointure et à l'actualisation des salons ; le démarrage peut être demandé à l'API.
- **Les écrans Flutter de manche et de résultats et leur raccordement aux endpoints de manches/réponses restent à implémenter.**
- Firebase a été écarté pour cette implémentation ; ne pas ajouter de configuration Firestore ou Cloud Functions au dépôt Flutter.
- **Reste pour valider la phase** : créer les écrans manquants, déployer/configurer l'API, puis tester sur plusieurs appareils. Le podium et l'historique multijoueur restent à faire.

## Phase 8 — Animations et finitions
- Logo lettres tombantes, tuiles 3D, roue, anneau + alerte rouge, validation, podium+confettis, transitions écran. RepaintBoundary, 60fps visé (mesures notées, jamais affirmées).

## Phase 9 — Paliers 5.2/5.3 du cahier
- Implémenter ce qui est réaliste (vérification en ligne côté serveur, envoi…), lister précisément ce qui est écarté et pourquoi (équipes, même téléphone, bots IA, spectateurs, défi quotidien, badges, packs, thèmes, anglais).

## Phase 10 — Recette finale
- Relecture des critères, README complet, documentation de l'API Laravel, `docs/ARCHITECTURE.md`, `docs/PROGRESSION.md`, `docs/TRACABILITE.md`, `docs/RESTE_A_FAIRE.md`, compte rendu final structuré.
