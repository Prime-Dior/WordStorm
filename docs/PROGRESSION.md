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

## Phase 2 — Moteur de règles ⏳ non commencée
