# WordStorm

WordStorm est un jeu de catégories de mots inspiré du Petit Bac.

## Organisation

- `frontend/` : application Flutter.
- `docs/` : cahier des charges, procédures et suivi.
- `backend/` : ancien emplacement Firebase, non utilisé par le client actuel.
- [Dépôt API Laravel](https://github.com/Alecdev-10/wordstorm-api) : salons et validation des réponses multijoueurs.

Le mode solo fonctionne localement, sans réseau. Le multijoueur utilise le dépôt API séparé ; l'application et l'API doivent être configurées et disponibles pour jouer en ligne. La validation se fait avec le dictionnaire embarqué côté serveur, puis le Wiktionnaire en complément. Il n'y a pas de clé d'IA.

## Préparer et lancer Flutter

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

Voir [frontend/README.md](frontend/README.md) pour l'URL de l'API et les adresses locales selon la plateforme. Voir le README du dépôt `wordstorm-api` pour installer et démarrer le serveur.

## Vérifier les changements

Depuis `frontend/` :

```powershell
dart format lib
flutter analyze
flutter test
```

Depuis le dépôt API :

```powershell
vendor/bin/phpunit
```

## Documents utiles

- [Environnement de développement](docs/ENVIRONNEMENT.md)
- [Progression](docs/PROGRESSION.md)
- [Travail restant](docs/RESTE_A_FAIRE.md)
- [Plan](docs/PLAN.md)
- [Cahier des charges](docs/Cahier_des_charges_Wordstorm_Flutter.docx)
