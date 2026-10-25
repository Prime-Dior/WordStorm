# PROGRESSION — suivi au fil des phases

## Phase 0 — Reconnaissance ✅ (2026-10-24)
- Sources lues intégralement : prompt de mission (208 l.), cahier des charges WT (273 l. extraites, sect. 1–21 + Annexe A + Complément), maquette HTML `Wordstorm_maquette_v4/wordstorm.html` (HTML/CSS/JS complets), planche Figma rastérisée (`Wordstorm_planche_statique.png`, 19 écrans), prototype Petit Bac (`wordLists.js` 2 226 mots, `gameLogic.js`, `letters.js`, `categories.js`).
- Environnement : Flutter 3.47.7 ✅, Dart 3.13.5 ✅, Chrome ✅, Git ✅, Android SDK ❌ (installation à prévoir), iOS impossible (Windows).
- Livrables de phase : `docs/ANALYSE.md`, `docs/QUESTIONS.md` (7 questions, comportements provisoires appliqués), `docs/PLAN.md`.
- Divergences sources consignées : 10 cas (voir ANALYSE §5).
- Branch de travail : `feature/app-complete`.

## Phase 1 — Socle ⏳ en cours
- Projet Flutter créé dans le dépôt (`flutter create`, cibles android/ios/web, org `com.primael`).
- Dépendances : flutter_riverpod, go_router, flutter_svg, shared_preferences ; flutter_lints 6 + lints stricts de projet.
- Polices TTF téléchargées (Google Fonts, OFL) : Bangers, Poppins x3, RobotoMono (wght).
- Assets : images maquette (héros + 4 avatars) ; `assets/words/words.json` généré depuis `wordLists.js` (18 listes / 2 226 mots).
- `lib/core` : AppColors (palette relevée), AppTheme (typographies), WordstormIcons (25 glyphes exacts de la maquette), ArcadeButton (6 variantes), LetterTile 3D, CategoryBadge, ResponseRow, CheckRow (verrouillée/inactive), PlayerCard, CodeField (sans ambigus), CitySkyline + Sunburst (CustomPainter), WordstormLogo (contour épais + dégradés), ScreenScaffold.
- `lib/app` : go_router (13 routes, transition fade+scale 350 ms ≈ maquette).
- Écrans : Accueil et Menu (fidèles à la maquette au socle près) ; autres écrans = PlaceholderScreen clairement marqués (phase 4).
- CI : `.github/workflows/ci.yml` (format --set-exit-if-changed + analyze --fatal-infos + test).
- `docs/ENVIRONNEMENT.md` : flutter doctor consigné ; Android SDK à installer.
- **Traitement effectué** : `dart fix --apply`, `dart format` (21 fichiers), `flutter analyze` **No issues found**, `flutter test` **+4 : All tests passed** (salon_code + smoke).

## Phase 2 — Moteur de règles ✅ (2026-10-24)
- **Dart pur** sous `lib/domain` (aucun import Flutter — testable hors widgets) :
  - `categories.dart` : 5 obligatoires (cadenas) + 15 optionnelles, max 12/partie,
    mode aléatoire = socle + 4, manches 1–5, validation de sélection (doublons, plafond).
  - `rules_config.dart` : barème 15/10/5/0 + réutilisé = 5, `ConflictPolicy`
    (`reuseWins` par défaut, **provisoire**, question Q1), lettres difficiles K W X Y Z
    excluses par défaut, durées de manche [20,30,45,60,90,120,0], soloMode.
  - `normalization.dart` : portage `gameLogic.js` — minuscules, accents supprimés
    (NFD simulé + œ/æ), filtre de saisie (lettres/accents/espaces/tirets/apostrophes),
    première lettre insensible casse/accents.
  - `validation.dart` : vide / mauvaise lettre / trop court (2 l. ; Prénom 3 l.
    sans dictionnaire, règle souple maquette) / dictionnaire injecté en callback
    (`true`/`false`/`null` = validation souple pour catégories sans liste,
    Q2) ; `UsedWords` inter-manches (même mot toléré dans une autre catégorie).
  - `scoring.dart` : paliers `onlyValid` 15 (bonus, aussi en solo) / `uniqueValid` 10 /
    `shared` 5 / invalide 0, réutilisé 5, conflit réutilisation × bonus arbitré par
   ConflictPolicy avec badge « Règle à trancher », justifications en français
    (« Seule réponse valide · bonus », « Ne commence pas par R », « Pas de réponse »…).
  - `draws.dart` : tirage de lettre (pool A–Z **moins K W X Y Z, Q inclus** —
    divergence maquette consignée), sans répétition dans la partie, remise en jeu
    si pool épuisé ; tirage aléatoire 5 + 4 sans doublon.
- **Tests** (`test/domain/`, 55 nouveaux cas) : barème, deux politiques de conflit,
  normalisation, règle Prénom ≥ 3, réutilisation inter-manches (y compris « autre
  catégorie autorisée »), lettre tirée (exclusions/no-repeat), catégories aléatoires,
  et **exemple de référence du cahier §16.1 : Anna 35 / Ben 15 / Cyril 15** (scénario
  inféré couvrant tous les paliers, documenté dans le test lui-même).
- **Exécution réelle** : `dart format` OK, `flutter analyze` **No issues found**,
  `flutter test` **+59 : All tests passed** (55 moteur + 4 socle).

## Phase 3 — Dictionnaire + dépôts locaux ✅ (2026-10-24)
- `lib/data/dictionary/dictionary_repository.dart` : contrat + mapping catégories
  Wordstorm → listes Petit Bac. Couvertes : Prénom, Ville, Pays, Animal, Objet,
  Métier, Sport, Partie du corps ; partielles : Fruit/Légume ← « Fruit ou légume »
  (listes mélangées, faux positifs possibles — provision Q2), Marque de voiture ←
  « Marque », Groupe de musique ← « Chanteur ou groupe ».
- `lib/data/dictionary/asset_dictionary_repository.dart` : chargement de
  `assets/words/words.json` (2 226 mots / 18 listes) **hors main isolate** (`compute`),
  mots normalisés à l'import ; catégories sans liste → `null` → validation souple (Q2).
- `lib/data/settings/settings_repository.dart` : pseudo, sons, vibrations, animations
  réduites — persistés (shared_preferences), défauts = tout actif.
- **Tests** (`test/data/`, 9 cas) : chargement réel de l'asset (18 listes, 2 226 mots,
  normalisation), mapping complet, branches du moteur avec le dictionnaire réel
  (« Rat » validé / « Zzzorge » refusé / Fleuve souple), réglages persistés.
- **Exécution réelle** : `dart format` OK, `flutter analyze` **No issues found**,
  `flutter test` **+68 : All tests passed**.

## Phase 4 — Écrans et navigation ✅ (2026-10-24)
- **Providers applicatifs** (`lib/app/providers.dart`) : dictionnaire, réglages,
  session de jeu (riverpod) — injections interchangeables, le multi de la phase 7
  introduira un provider de salon sans toucher au moteur.
- **Session de jeu** (`lib/features/game/state/solo_session.dart`) :
  `GameSetup` (liste de catégories figée, durée, manches 1–5, lettres difficiles) →
  `start` / `drawLetter` (un tirage par manche, sans répétition dans la partie,
  paramètre `forced` réservé aux tests) / `setAnswer` / `endTurn`
  (validation + score via le moteur **pur**, mots consommés enregistrés
  inter-manches) / `nextRound` / `restart`. État immutable ;
  `RoundResult` prêt pour l'écran de résultats.
- **Écrans réels** (remplacent tous les placeholders) :
  - Configuration (Figma 03/08) : Aléatoire (socle 5 + 4, non modifiable, liste
    figée au lancement) / Personnalisé (max 12, obligatoires cadenassées),
    durées [20·Speed, 30, 45, 60, 90, 120, sans chrono], stepper manches 1–5,
    option K W X Y Z, CTA LANCER (solo) ou CRÉER LE SALON (multi).
  - Tirage/Fig. roue (Figma 10) : roue CustomPaint 21 segments, 3,4 s
    easeOutCubic +1440°, lettre du moteur sous le pointeur, navigation
    automatique vers la manche.
  - Manche (Figma 05/11) : tuile de lettre, chrono (lin, rouge ≤ 10 s),
    lignes de réponse, progression « n / N », VALIDER (chrono) / STOP
    (sans chrono, grisé tant que tout n'est pas rempli), **fin automatique
    à 0 s** (validation + résultats).
  - Résultats de manche (Figma 12) : réponse, points, justification
    française par catégorie, total, badge « Règle à trancher » si conflit
    réutilisation ; bouton Manche suivante (→ roue) ou Terminer (→ fin).
  - Fin de partie (Figma 07/13) : score total des manches solo,
    REJOUER (même config, historique remis à zéro) et MENU. Podium multi
    à la phase 7.
  - Rejoindre (Figma 06) : code 6 signes sans ambigus + pseudo ; validation
    de forme locale, recherche du salon honnêtement à la phase 7.
  - Salon (Figma 04/09) : état honnête « salons en ligne à la phase 7 »,
    rien de simulé.
  - Paramètres (Figma 18) : branché sur `SettingsRepository` (pseudo, sons,
    vibrations, animations réduites).
  - Règles (Figma 19) : barème, réutilisation provisoire marquée, lettres,
    manches, règle souple Prénom — fidèles au moteur réel.
  - Historique : annonce la phase 6 (enregistrement local des parties).
  - Statut générique (Figma 14–17) : ATTENTE / ERREUR / SALON INTROUVABLE.
- **Corrections structurelles levées par les tests** :
  - `ScreenScaffold` : couche `Material` translucide sous le contenu — les
    `TextField`/`Switch` n'ont plus d'écran rouge (le bug aurait planté
    l'app réelle, pas seulement les tests).
  - `UsedWords.clear()` exposé (redémarrage de partie).
- **Routeur** : 13 routes réelles + /not-found.
- **Menu** : Solo/Multijoueur → `/config?mode=…`, OK code → `/join`,
  Classement → `/history`.
- **Exécution réelle** : `dart format` OK, `flutter analyze`
  **No issues found**, `flutter test` **+75 : All tests passed**
  (nouvelles : 6 session contrôleur avec dictionnaire réel + 1 parcours
  widget manche→VALIDER→résultats).

## Phase 5 — Solo complet hors ligne ✅ (2026-10-24)
- **Parcours e2e exécuté et vert** (`test/app/solo_flow_e2e_test.dart`) :
  Menu → Configuration solo (sans chrono, 3→1 manches) → tirage de la roue
  (3,4 s) → saisie des 5 obligatoires → STOP → résultats de manche
  (barème appliqué en direct) → fin de partie → **REJOUER** → nouvelle
  roue → nouvelle manche. Le **dictionnaire réel** est branché partout,
  les points de scoring réels s'affichent. 76/76 tests, analyze 0.
- **Deux bugs réels trouvés par l'intégration** :
  1. `WheelScreen` tirait la lettre **pendant la construction** de l'arbre
     (riverpod interdit : « Tried to modify a provider while the widget
     tree was building ») → tirage différé en post-frame callback ;
     la roue plantait même sur un vrai appareil.
  2. En **sans-chrono**, STOP restait grisé pour toujours : l'écran de
     manche ne se reconstruisait pas à la saisie (champ `onChanged` vide)
     → `setState` branché, la progression « n / N » et le STOP sont
     désormais en direct. (Sur un appareil réel, le STOP était inutilisable.)
- **Tests d'intégration écrits, non exécutables dans cet environnement** :
  `integration_test/solo_e2e_test.dart` + `test_driver/` couvrent le même
  parcours pour un appareil réel (`flutter drive … -d chrome|windows`).
  - `flutter drive -d chrome` : Chrome 123 est détecté mais le service de
    debug DWDS n'aboutit jamais (« Waiting for connection… » figé, aucune
    fenêtre Chrome n'apparaît, repeat avec `--web-port=8090` : identique).
  - `flutter drive -d edge` : Edge se lance (9 processus) mais même
    blocage DWDS figé.
  - `flutter drive -d windows` : nécessite le **Mode Développeur**
    (liens symboliques) — à exécuter une fois le réglage activé.

## Phase 6 — Historique / accessibilité / sons ✅ (2026-10-25)
- **Historique réel** (`lib/data/history/history_repository.dart`) :
  `GameRecord` (id, date ISO, mode, manches, total, catégories, lettres) ;
  persistance `shared_preferences` (clé `wordstorm.history.v1`), tri du
  plus récent, déduplication par id, plafond 100 parties, `clear()`,
  `statsOf()` (parties / meilleur / moyenne arrondie sup. / dernier).
  Controller solo : toute partie **terminée** s'enregistre
  (`endTurn` async, état mis à jour de façon synchrone avant le premier
  await — l'écran de résultats est affiché sans délai).
- **Écran historique** (menu → classement) : liste des parties (date
  « 24/10 2026 », mode, lettres tirées, total + PTS), bandeau stats
  PARTIES / MEILLEUR / MOYENNE, état vide honnête + bouton JOUER,
  bouton EFFACER (confirmation) ; pas de classement global (décision §5-10).
- **Sons générés** (`lib/core/audio/sound_engine.dart`, dépendance ajoutée :
  `audioplayers ^6.8.1`) : 5 sons **synthétisés en Dart** (WAV PCM 16 bits
  mono 22 kHz, notes sine + enveloppe anti-clic, glissando) — roue
  (glissando descendant 0,9 s), démarrage de manche, blips des **5
  dernières secondes**, validation (arpège majeur), victoire (fanfare).
  Aucun asset binaire. Lecture `BytesSource`, lecteur déchargé après
  lecture, tout en try/catch best-effort (ne casse jamais le flux de jeu,
  y compris dans les tests sans plugin).
- **Vibrations** (`HapticFeedback` light/medium/heavy) gouvernées par le
  réglage local, aux mêmes déclencheurs.
- **Accessibilité** :
  - cibles tactiles ≥ 48 dp sur tous les `ArcadeButton` ;
  - sémantique : tuiles de lettre audibles (« Lettre R »), pastilles
    décoratives exclues de la lecture, boutons déjà `Semantics(button)`;
  - « animations réduites » **au réglage système ET applicatif** (fusion
    à la racine de l'app dans `MediaQuery.disableAnimations`) :
    Sunburst fixe, roue sans animation (lettre directe, navigation
    immédiate).
- **Quitter branché** (restant phase 1) : `SystemNavigator.pop()`.
- **Tests** : 10 dépôt d'historique (persistance, dédup, tri, plaf 100,
  clear, aller-retour JSON, dateLabel, stats) + 2 session (enregistrement
  session (enregistrement réellement appelé en fin de partie avec total
  juste, **non** appelé si la partie continue) + 6 audio (en-têtes RIFF/WAVE valides, non silence,
  gate du réglage sans toucher au canal plateforme) ; 2 bugs trouvés par
  les tests : `const []` non modifiable passée au cache (dédup plantait),
  `await` dans `endTurn` non-async + type non importé (le build natif/web
  ne compilait plus — attrapé par un build web de contrôle).
- **Build web release exécuté** : `flutter build web --release` OK
  (la démo tourne dans Chrome via un serveur statique — contourne le
  blocage DWDS du debug uniquement, le debug reste bloqué).
- **Exécution réelle** : `dart format` OK, `flutter analyze`
  **No issues found**, `flutter test` **+93 : All tests passed**.

## Phase 7 — Salons Firebase (prochaine)
