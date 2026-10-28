# WordStorm Flutter

Application Flutter du dépôt WordStorm. Le mode solo reste local et hors ligne. Le multijoueur utilise le dépôt Laravel séparé `https://github.com/Alecdev-10/wordstorm-api`.

## Dépendances et lancement

Depuis `frontend/` :

```powershell
flutter pub get
flutter run -d chrome
```

Le client utilise `http` pour les appels API et `flutter_secure_storage` pour conserver le jeton joueur. Android nécessite API 23 ou supérieure. Le trafic HTTP non chiffré est autorisé uniquement en build debug Android pour le serveur local ; une version publiée doit utiliser HTTPS.

## Adresse de l'API

L'adresse peut être fournie au lancement avec `--dart-define=WORDSTORM_API_URL=...` :

```powershell
flutter run -d chrome --dart-define=WORDSTORM_API_URL=http://127.0.0.1:8000/api/v1
```

Valeurs locales par défaut : navigateur/Windows `http://127.0.0.1:8000/api/v1`, émulateur Android `http://10.0.2.2:8000/api/v1`. Pour tester sur Android, lancer Laravel avec `php artisan serve --host=0.0.0.0`, garder le téléphone et l'ordinateur sur le même réseau et remplacer l'adresse par l'IP locale de l'ordinateur. L'API doit être configurée pour autoriser l'origine web locale si Flutter Web est utilisé.

## Parcours en ligne

L'hôte choisit les catégories, la durée et le nombre de manches, puis crée le salon. Les autres joueurs le rejoignent avec le code et leur pseudo. L'état du salon est actualisé toutes les deux secondes ; le serveur tire les lettres, conserve les réponses et calcule les scores. Une réponse non concluante du dictionnaire apparaît « à vérifier » et l'hôte peut l'accepter ou la refuser.

Le dictionnaire local `assets/words/words.json` sert au solo. L'API possède sa copie pour valider les parties multijoueurs ; la synchronisation est expliquée dans le README du dépôt API. Aucune clé d'IA n'est requise.

## Vérification

```powershell
dart format lib
flutter analyze
flutter test
```

La configuration et les règles d'API sont documentées dans `../docs/ENVIRONNEMENT.md` et dans le README du dépôt `wordstorm-api`.
