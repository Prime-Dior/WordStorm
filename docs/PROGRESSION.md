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

## Phase 3 — Dictionnaire + dépôts locaux ⏳ non commencée
