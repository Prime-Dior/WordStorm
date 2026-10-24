# ENVIRONNEMENT — relevé `flutter doctor` (2026-10-24)

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
- Build Tools 2019 incomplets → cible desktop Windows non utilisée (hors périmètre du cahier).

## Git
- Dépôt de mission : `C:\Users\Zbook\Wordstorm` (remote `origin/main`).
- Branche de travail : `feature/app-complete` (commits Conventional).

## Polices
- WOFF2 de la maquette non compatibles Flutter : TTF officiels Google Fonts
  (Bangers-Regular, Poppins Regular/SemiBold/Bold, RobotoMono variable) téléchargés
  dans `assets/fonts/` — licence OFL, redistribuables.
