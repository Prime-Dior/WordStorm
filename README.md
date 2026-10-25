# WordStorm

WordStorm est un jeu de catégories de mots inspiré du Petit Bac. Le dépôt sépare maintenant l'application mobile du futur backend pour que chacun puisse travailler sur une interface ou une partie serveur sans mélanger les fichiers.

## Organisation du dépôt

```text
WordStorm/
├── frontend/                 Application Flutter
│   ├── lib/
│   │   ├── app/               Démarrage et navigation
│   │   ├── core/              Thème, widgets communs et utilitaires
│   │   ├── data/              Accès aux données locales
│   │   ├── domain/            Règles, validations et calculs
│   │   └── features/          Écrans regroupés par fonctionnalité
│   ├── assets/                Images, polices et dictionnaire
│   ├── test/                  Tests unitaires et widgets
│   └── integration_test/      Parcours de l'application
├── backend/                   Services serveur (à venir)
│   └── firebase/              Emplacement prévu pour Firebase
├── docs/                      Cahier des charges, plan, suivi et maquettes
│   └── maquettes/             Fichiers de maquette SVG
└── .github/workflows/         Vérifications automatiques
```

Le client Flutter est dans `frontend/`. Le backend n'est pas encore configuré : le multijoueur en ligne et les fonctions serveur restent planifiés pour la phase Firebase. Le jeu solo et plusieurs parcours locaux sont déjà dans le frontend. Les tâches restantes sont listées dans [docs/RESTE_A_FAIRE.md](docs/RESTE_A_FAIRE.md) et l'avancement dans [docs/PROGRESSION.md](docs/PROGRESSION.md).

## Préparer son poste

Installer Flutter et Git, cloner le dépôt, puis récupérer les paquets de l'application :

```powershell
git clone https://github.com/Prime-Dior/WordStorm.git
cd WordStorm
cd frontend
flutter pub get
```

Dans VS Code, ouvrir le dossier `frontend/` pour travailler sur l'application. Le lancement normal ouvre l'aperçu téléphone des seuls écrans déjà réalisés : accueil, menu, configuration et salon. Les autres écrans du socle ne sont pas accessibles depuis cette présentation. Pour la lancer dans Chrome :

```powershell
flutter run -d chrome
```

Pour vérifier les modifications :

```powershell
dart format lib test
flutter analyze
flutter test
```

## Faire une interface

Les interfaces sont regroupées par fonctionnalité dans `frontend/lib/features/`. Par exemple, l'accueil se trouve dans `home/home_screen.dart`, la configuration dans `config/config_screen.dart`, le jeu dans `game/game_screen.dart` et les résultats dans `results/`.

Pour prendre en charge un écran :

1. Récupérer les dernières modifications de `main`, puis créer une branche avec un nom lié à la tâche :

   ```powershell
   git switch main
   git pull --ff-only
   git switch -c feature/ui-nom-ecran
   ```

2. Créer ou modifier l'écran dans `frontend/lib/features/<fonctionnalite>/`. Garder les composants propres à cet écran dans le même dossier.
3. Réutiliser les styles de `frontend/lib/core/theme/` et les widgets de `frontend/lib/core/widgets/`. Ajouter les images ou polices dans `frontend/assets/` et les déclarer dans `frontend/pubspec.yaml` si nécessaire.
4. Si l'écran doit être accessible par une nouvelle URL interne, ajouter sa route dans `frontend/lib/app/router.dart`. Ce fichier est partagé : prévenir l'équipe avant de modifier des routes en parallèle pour éviter les conflits.
5. Ajouter les tests dans `frontend/test/`, puis lancer `dart format lib test`, `flutter analyze` et `flutter test` depuis `frontend/`.
6. Envoyer une pull request vers `main` en indiquant l'écran modifié, les tests exécutés et une capture si l'apparence a changé.

Chacun peut travailler sur son écran dans une branche séparée. Pour les interfaces qui utilisent un composant commun, proposer d'abord le changement dans `core/widgets` ou `core/theme` afin que les autres écrans gardent le même style. Les interfaces à prendre en charge se choisissent dans les tâches du dépôt et dans `docs/RESTE_A_FAIRE.md`.

## Backend

`backend/` est réservé aux services serveur. Le plan actuel prévoit Firebase pour les salons et le multijoueur ; cette partie n'est pas encore initialisée. Avant son démarrage, le dépôt ne contient pas de règles Firestore, de Cloud Functions ni de configuration Firebase. Ne pas ajouter de clé privée, de fichier `.env` rempli ou de secret au dépôt. Les conventions du backend seront ajoutées dans `backend/firebase/README.md` au début de cette phase.

## Documents utiles

- [Maquette SVG](docs/maquettes/wordstorm-maquette.svg)
- [Cahier des charges](docs/Cahier_des_charges_Wordstorm_Flutter.docx)
- [Plan des phases](docs/PLAN.md)
- [Progression](docs/PROGRESSION.md)
- [Travail restant](docs/RESTE_A_FAIRE.md)
- [Environnement de développement](docs/ENVIRONNEMENT.md)
