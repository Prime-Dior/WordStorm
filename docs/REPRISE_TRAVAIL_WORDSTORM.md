# Reprise du travail WordStorm

État vérifié le 26 octobre 2026. Ce document sert de point de reprise à une autre session ou à un autre agent. Lire d’abord cette page, puis le guide local indiqué plus bas avant de modifier les écrans.

## État actuel du dépôt

- Dépôt GitHub : `https://github.com/Prime-Dior/WordStorm`
- `origin/main` : `281cf74` — PR #6, dernière intégration visible au moment de cette mise à jour.
- PR #3, #4, #5 et #6 sont fusionnées. Il n’y avait aucune autre PR ouverte à la dernière vérification.
- PR #7 : [Décrire l’aperçu centré dans le README](https://github.com/Prime-Dior/WordStorm/pull/7), branche `fix/retablir-cadre-smartphone`, vers `main`.
- La PR #7 conserve le rendu centré actuel et met à jour le README. Elle ne réintroduit pas de coque dessinée autour du téléphone.
- Après l’ajout de cette note de reprise, vérifier à nouveau la CI de la PR #7 : le nouveau commit déclenchera un contrôle.

Le rendu voulu est celui déjà présent dans `main` : sur ordinateur, l’aperçu est centré dans Chrome, sans fausse coque. Sur un écran plus étroit, il s’adapte à la largeur disponible jusqu’à 430 pixels. Dans `frontend/lib/app/showcase_app.dart`, ce comportement est porté par `_ShowcaseViewport` (`ColoredBox`, `Center`, `ConstrainedBox(maxWidth: 430)`).

La présentation expose les routes `/`, `/menu`, `/config`, `/lobby`, `/settings`, `/rules`, `/waiting`, `/loading`, `/connection-error` et `/not-found`. Les pages de règles et paramètres et les états de salon s’affichent comme overlays. Le README indique maintenant cette portée.

## Copies locales et branches

### Copie de travail à utiliser

- Dossier : `C:\Users\Zbook\WordStorm-lobby-review`
- Branche courante attendue : `fix/retablir-cadre-smartphone`
- Dossier Flutter : `C:\Users\Zbook\WordStorm-lobby-review\frontend`
- Cette copie est à jour avec le `main` récent et contient la branche de la PR #7.
- Pour reprendre la PR, vérifier `git status --short`, puis `git log -5 --oneline` et `gh pr view 7`.

### Autre copie locale à préserver

- Dossier : `C:\Users\Zbook\WordStorm`
- Branche : `feature/app-complete`, pointe localement vers `26bf403` au moment de cette note.
- Une modification locale non commitée existe dans `frontend/lib/features/wheel/wheel_screen.dart`.
- Ne pas la supprimer, la restaurer, la déplacer ni l’ajouter à un commit. Cette autre copie n’est pas à jour avec `origin/main`.

### Maquette et guide explicatif

- Maquette SVG dans la copie de travail actuelle : `C:\Users\Zbook\WordStorm-lobby-review\docs\maquettes\wordstorm-maquette.svg`.
- Une copie existe aussi dans `C:\Users\Zbook\WordStorm\docs\maquettes\wordstorm-maquette.svg`.
- Guide de code, local seulement : `C:\Users\Zbook\Downloads\Guide_explicatif_WordStorm.docx`.
- Ne pas ajouter le guide de code au dépôt ni créer de lien vers lui dans le README. Après une modification du code des écrans, mettre à jour le guide local afin qu’il décrive les fichiers et le rendu présents.
- Le guide explique maintenant le viewport centré et le comportement sur smartphone. Le document de reprise, lui, peut rester dans `docs/` pour aider l’équipe et les prochains agents.

## Organisation du code

- `frontend/lib/main.dart` : point de départ Flutter et `ProviderScope`.
- `frontend/lib/app/showcase_app.dart` : routes de la présentation, overlays et viewport centré.
- `frontend/lib/app/router.dart` : routes de l’application complète.
- `frontend/lib/core/widgets/` : widgets partagés, dont logo, boutons, champ de code et tuiles.
- `frontend/lib/features/home/home_screen.dart` : accueil.
- `frontend/lib/features/menu/menu_screen.dart` : menu et saisie du code.
- `frontend/lib/features/config/config_screen.dart` : configuration.
- `frontend/lib/features/lobby/` : écran de salon et données de préparation.
- `frontend/lib/features/settings/`, `rules/` et `skeleton/` : paramètres, règles et états de démonstration ajoutés dans les dernières PR.
- Les autres dossiers sous `frontend/lib/features/` contiennent d’autres écrans du jeu ; ils ne sont pas tous reliés à la présentation.

### Parcours des routes de présentation

`ShowcaseApp` est l’application d’aperçu utilisée par `main.dart`. Les routes qu’elle autorise sont définies dans `showcase_app.dart`. Une nouvelle page doit être ajoutée à cette liste pour être accessible dans la présentation ; ajouter une route uniquement dans `router.dart` ne l’ajoute pas automatiquement à l’aperçu.

Les chemins disponibles sont :

- `/` : accueil
- `/menu` : menu
- `/config` : configuration
- `/lobby` : salon
- `/settings` : paramètres
- `/rules` : règles
- `/waiting`, `/loading`, `/connection-error`, `/not-found` : états de démonstration

## Historique utile

- Chris a créé le salon dans le commit `3ac999f` (`Chris20071234`).
- Les changements d’intégration et de présentation sont dans des commits séparés, puis ont été fusionnés avec la PR #3.
- La PR #4 avait échoué à l’analyse parce que le test du projet modèle instançait `MyApp`, qui n’existait plus après le changement d’entrée. Le retrait de ce test avait ensuite permis à la CI de passer dans la PR #3. Les PR #5 et #6 ont aussi passé leur CI et sont fusionnées.
- Les PR #5 et #6 ont ajouté des écrans de paramètres, de règles et d’états, puis corrigé leur apparence. La présentation actuelle n’est donc plus limitée aux quatre routes initiales.
- La modification de cadre smartphone faite dans une première version de la PR #7 n’a pas été fusionnée. Le commit actuel de cette PR garde le viewport centré et corrige le README.

## Lancer l’application

Dans PowerShell :

```powershell
cd C:\Users\Zbook\WordStorm-lobby-review\frontend
flutter pub get
flutter run -d chrome
```

Chrome affiche le rendu Flutter. Le centrage et la largeur maximale sont gérés par `_ShowcaseViewport` dans Flutter ; Chrome ne dessine pas de téléphone.

## Vérifier la PR #7

```powershell
cd C:\Users\Zbook\WordStorm-lobby-review
git status --short
gh pr view 7 --json url,state,isDraft,mergeStateStatus,mergeable,statusCheckRollup
gh pr checks 7
```

Au dernier contrôle avant cette mise à jour documentaire, la PR était sans conflit et la CI avait réussi. Le nouveau commit de ce document déclenche une nouvelle CI : attendre son résultat avant de la fusionner. La règle de `main` demandait zéro approbation à la dernière vérification ; revérifier la règle si GitHub bloque la fusion.

## Après la PR #7

Quand la PR #7 est fusionnée, synchroniser la branche locale `main` dans cette copie de travail, puis créer une branche séparée pour le prochain écran :

```powershell
cd C:\Users\Zbook\WordStorm-lobby-review
git switch main
git pull --ff-only origin main
git switch -c feature/ui-nom-ecran
```

Développer l’écran sous `frontend/lib/features/<nom>/`. Réutiliser `core/widgets/` et `core/theme/`. Si l’écran doit être visible dans l’aperçu, mettre à jour `ShowcaseApp` et son registre de routes ; mettre aussi à jour le guide Word local dans Téléchargements.

Commits en français. Avant chaque commit, vérifier l’état du dépôt et n’ajouter que les fichiers de la tâche :

```powershell
git status --short
git add <fichiers-de-la-tache>
git commit -m "Décrire le changement en français"
git push -u origin feature/ui-nom-ecran
```

Créer une PR vers `main` ; ne pas pousser directement sur `main`. La PR #7 et les règles de branche doivent être vérifiées séparément avant fusion.

## Identité Git

Avant de créer un commit dans un nouvel environnement :

```powershell
git config user.name
git config user.email
```

L’identité actuelle observée est `Prime Dior` / `princeprimo43@gmail.com`. Ne pas réécrire les commits de Chris ni modifier son auteur.
