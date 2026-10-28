# WordStorm

WordStorm est un jeu de catégories de mots inspiré du Petit Bac.

## Organisation

- `frontend/` : application Flutter.
- `docs/` : cahier des charges, procédures et suivi.
- `backend/` : ancien emplacement Firebase, non utilisé par le client actuel.
- [Dépôt API Laravel](https://github.com/Alecdev-10/wordstorm-api) : salons et validation des réponses multijoueurs.

Le mode solo fonctionne localement, sans réseau. Flutter est relié à l'API pour les sessions, la création/rejointure et l'affichage des salons. Les écrans de manche et de résultats multijoueur restent à faire ; le parcours en ligne n'est pas complet. L'API contient la validation lexicale (dictionnaire local puis Wiktionnaire), sans clé d'IA.

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
