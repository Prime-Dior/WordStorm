# ENVIRONNEMENT — relevé `flutter doctor` (2026-10-24)

## Multijoueur Laravel (mise à jour 2026-10-28)
- Le client utilise le dépôt séparé `https://github.com/Alecdev-10/wordstorm-api`.
  Suivre son README pour PHP, Composer, MySQL, migration et lancement.
- URL Flutter : `--dart-define=WORDSTORM_API_URL=https://adresse/api/v1`.
  Défaut web/Windows : `http://127.0.0.1:8000/api/v1` ; Android Emulator :
  `http://10.0.2.2:8000/api/v1`. Sur téléphone physique, utiliser l'IP LAN du
  poste qui lance Laravel avec `php artisan serve --host=0.0.0.0`.
- Flutter Web requiert une origine de développement autorisée par CORS dans
  l'API. Le build Android debug accepte HTTP local ; la version publiée doit
  pointer vers HTTPS. Jetons invités conservés dans le coffre sécurisé système.
- L'API possède une copie de `frontend/assets/words/words.json`. Les mises à jour
  du lexique doivent être copiées et documentées dans le README du dépôt API.
- Aucun service d'IA ni clé d'API d'IA n'est utilisé.

## Poste de travail
- Windows 11 Professionnel 22H2, locale `fr-BJ`.

## Flutter / Dart
- **Flutter 3.47.7 stable** (`C:\dev\flutter`) — ✅
- Dart 3.13.5 — ✅
- Chrome 123 / Edge — ✅ (cible de vérification en attendant le SDK Android)

## Android (cible principale)
- `flutter doctor` : ❌ **Android SDK introuvable** (`ANDROID_HOME` vide, aucun dossier Sdk).
- Matériel de réinstallation disponible : `C:\Users\Zbook\Downloads\cmdline-tools.zip` (155 Mo).
- Étapes manuelles à effectuer (à documenter précisément lors de l'installation réelle) :
  ```powershell
  # 1. Extraire le cmdline-tools dans %ANDROID_HOME%\cmdline-tools\latest
  # 2. sdkmanager --licenses   (accepter toutes les licences)
  # 3. sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
  # 4. flutter config --android-sdk <chemin>
  # 5. flutter doctor
  ```
- Émulateur : à créer après l'installation du SDK (`avdmanager create avd ...`).
- **Par défaut pendant ce laps** : toute validation Android/iOS qui exige un appareil
  est signalée comme *non exécutée* tant que l'émulateur n'est pas prêt.

## iOS
- Impossible sur ce poste (pas de Mac). Contrainte permanente de l'environnement ;
  la cible iOS restera non testée par exécution.

## Visual Studio (desktop Windows)
- Build Tools 2019 incomplets (« Développement pour le bureau avec C++ » à
  cocher dans Visual Studio Installer : MSVC v142 + Windows 10 SDK 10.0.19041
  + CMake) → `flutter drive -d windows` bloqué tant que la réparation n'est
  pas faite. Desktop Windows reste hors périmètre du cahier (bonus seul).

## Web debug / release (2026-10-25)
- `flutter build web --release` : **OK** (build exécuté, `build/web`).
- `flutter drive/run` web/Tdebug : **bloqué** — Chrome et Edge se lancent
  mais restent sur « Waiting for connection from debug service » sans
  fenêtre visible (répété, port fixe modifié : identique). Premier suspect :
  pare-feu/antivirus sur le websocket du debug Dart ; Chrome se lance
  pourtant seul (`chrome.exe about:blank` a ouvert une vraie fenêtre).
- **Contourne pour la démo** : serveur statique sur le build release —
  ```powershell
  Set-Location C:\Users\Zbook\Wordstorm
  python -m http.server 8500 --directory build\web
  # → http://localhost:8500 dans Chrome (lecture seule, pas de rechargement
  #   à chaud ni debug — c'est un build release).
  ```
  Le mot clé : le debug web reste à éclaircir (pare-feu ?), le release
  fonctionne et sert la démonstration.

## Git
- Dépôt de mission : `C:\Users\Zbook\Wordstorm` (remote `origin/main`).
- Branche de travail : `feature/app-complete` (commits Conventional).

## Polices
- WOFF2 de la maquette non compatibles Flutter : TTF officiels Google Fonts
  (Bangers-Regular, Poppins Regular/SemiBold/Bold, RobotoMono variable) téléchargés
  dans `assets/fonts/` — licence OFL, redistribuables.
