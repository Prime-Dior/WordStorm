# ANALYSE — Phase 0 (reconnaissance)

Date : 2026-10-24 · Statut : phase 0 terminée (sources lues, inventaire établi)

---

## 1. Sources lues

| Source | Chemin | Ce qui en a été extrait |
|---|---|---|
| **Prompt de mission** | `C:\Users\Zbook\Downloads\PROMPT_Wordstorm_Flutter.md` (208 lignes) | Règles de conduite (§0), hiérarchie des sources (§1), décisions déjà prises qui priment sur le cahier (§4), plan de travail en 11 phases (§11), livrables (§12) |
| **Cahier des charges** | `docs/Cahier_des_charges_Wordstorm_Flutter.docx` (dans le dépôt ; copie identique dans Downloads, 10/22/2026) | Converti en texte (extraction XML, 273 lignes). Lu en entier : 21 sections + Annexe A + Complément (multijoueur/catégories) |
| **Maquette HTML (référence comportement/textes)** | `C:\Users\Zbook\Downloads\Wordstorm_maquette_v4\wordstorm.html` (54 Ko) + `assets/` | JS lu en entier : écrans, `RULES`, `validate`, `scoreRound`, catégories, chaînes FR, palette, durées, alphabet de code salon. Assets récupérés : `personnage_w.png`, `avatar_toi/lina/max/sami.png`, polices Bangers/Poppins/RobotoMono (**woff2**) |
| **Maquette Figma (référence visuelle)** | `C:\Users\Zbook\Downloads\Wordstorm_planche_vectorielle.svg` + version rastérisée `Wordstorm_planche_statique.png` (2830×2042) visualisée | 19 écrans/états identifiés et inventoriés (§3 ci-dessous). Export SVG = tracés (pédagogiquement illisible) ; la planche rastérisée sert de comparaison |
| ** Prototype Petit Bac / dictionnaire** | `C:\Users\Zbook\Downloads\Petit Bac\petit-bac-app\` (React/Expo, `node_modules` exclu) | `src/data/wordLists.js` = **dictionnaire de 2 226 mots sur 18 catégories** (§4 ci-dessous) ; `src/utils/gameLogic.js` (normalisation NFD, filtrage de saisie, règle du Prénom ≥ 3 lettres, tirage de lettre sans répétition) ; `src/data/letters.js` (`HARD_LETTERS = K W X Y Z`) |

La maquette HTML de `Wordstorm_maquette_v4` correspond exactement au dossier attendu (`wordstorm.html` + assets + fonts) : c'est la référence retenue. `Wordstorm_maquette.zip` est une copie équivalente.

## 2. Exigences principales (synthèse)

### Modes et navigation
- **Solo** (hors ligne, score personnel, aucun classement) et **Multijoueur en ligne** (salon à code, 2 à 8 joueurs).
- Menu : `Solo →`, `Multijoueur →`, bloc « Rejoindre avec un code » (6 caractères, validation, message d'erreur sous le champ), `Classement`.
- Pas de carte « Configuration » : la config est l'étape suivante de Solo/Multijoueur (écran « Nouvelle partie »).
- Code salon : 6 caractères, alphabet sans ambigus `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (pas de 0/O, 1/I). Code inconnu → écran « Salon introuvable ».

### Catégories (décision prioritaire, prompt §4)
- **5 obligatoires, non décochables, cadenas** : Prénom, Ville, Pays, Animal, Objet (Ville et Pays distincts).
- **Optionnelles** (cases à cocher) : Fleuve, Plante, Métier, Nourriture, Film, Sport, Partie du corps, Marque de voiture, Groupe de musique, Personnage de conte, Matière scolaire, Fruit, Légume, Maladie, Chanson.
- **Max 12 catégories** / partie. Mode **Aléatoire** (socle + 4 tirées au sort, non modifiables par l'hôte — nombre provisoire) ou **Personnalisé** (l'hôte coche). Mode visible de tous dans le salon ; liste **figée au lancement**, identique pour tous.

### Barème (centré dans le moteur, paramétrable)
| Cas | Points |
|---|---|
| Seule réponse valide de la catégorie (aussi en solo) | 15 |
| Réponse valide unique sans bonus | 10 |
| Réponse identique à celle d'un autre joueur | 5 |
| Vide ou invalide | 0 |
| Mot déjà utilisé, même catégorie, manche précédente | 5 (au lieu d'être refusé) |

En solo, toute réponse valide est la seule → 15 pts ; le palier 10 n'existe qu'en multijoueur. Le détail doit expliquer la règle appliquée.

### Manche
- Lettre tirée à la roue (ou par le serveur en ligne, identique pour tous).
- Durées : 20 s (« Speed »), 30, 45, 60, 90, 120 s, ou sans chrono ; manches 1–5 (borne provisoire) ; option « lettres difficiles » (K W X Y Z) **exclues par défaut**.
- Sans chrono : bouton **STOP** (grisé tant que toutes les catégories ne sont pas remplies) termine la manche pour tous ; STOP réservé à ce mode (provisoire).
- En ligne : l'heure de fin est fixée par le **serveur** (Cloud Functions) ; expulsion après 20 min d'inactivité en mode sans chrono.

### Multijoueur Firebase
Auth anonyme · Cloud Firestore (salons/joueurs/manches/réponses en temps réel) · Cloud Functions (heure de fin, lettre, verrouillage, calcul du score, vérification de mots) · règles de sécurité strictes (chacun n'écrit que ses réponses avant verrouillage ; réponses des autres invisibles avant la fin de manche ; score non modifiable par le client) · émulateur Firebase pour dev/test. Contestation et vote (§7.4 du cahier) : refus à la majorité, on ne vote pas sa propre réponse.

## 3. Inventaire des écrans (Figma/planche statique — 19 écrans + ajouts)

**Parcours principal** : 01 Accueil · 02 Menu principal · 03 Nouvelle partie (Solo, Aléatoire) · 04 Salon (hôte) · 05 Partie en cours · 06 Fin du temps · 07 Score final (solo).
**Variantes** : 08 Nouvelle partie (Personnalisé) · 09 Salon (invité « En attente de l'hôte… ») · 10 Tirage de la lettre (roue) · 11 Partie alerte ≤ 10 s · 12 Résultats de manche · 13 Classement final (podium).
**États/aides** : 14 Attente · 15 Chargement · 16 Erreur de connexion · 17 Salon introuvable · 18 Paramètres · 19 Règles du jeu.
**Ajouts attendus** : Nouvelle partie **Multijoueur** (Aléatoire/Personnalisé) avec « CRÉER LE SALON » · écran **« Rejoindre un salon »** (code → pseudo → salon) · **Salon à 1 joueur** avec « DÉMARRER · 1 JOUEUR » grisé · colonne de composants (bouton, ligne de réponse, tuile lettre, carte joueur, case à cocher, cadenas, champ de code).
**À supprimer** de la maquette : mentions « Simulation locale », « adversaires fictifs », « Simuler le démarrage par l'hôte ».

## 4. Dictionnaire Petit Bac (réutilisabilité)

`wordLists.js` — **2 226 mots, 18 catégories** : Prénom 110 · Animal 249 · Pays 120 · Ville 111 · Métier 154 · Fruit ou légume 105 · Objet 292 · Couleur 105 · Marque 132 · Instrument de musique 62 · Sport 69 · Chanteur ou groupe 72 · Athlète 83 · Adjectif 117 · Capitale 189 · Verbe 100 · Vêtement 87 · Partie du corps 69.

**Couverture catégorielle** (catégories Wordstorm → dictionnaire) :
- Couvertes directement : Prénom, Ville, Pays, Animal, Objet, Métier, Sport, Partie du corps.
- Couverture partielle / à adapter : Fruit, Légume ← « Fruit ou légume » (à dupliquer et trier) ; Marque de voiture ← « Marque » (à filtrer, non Restrictif) ; Groupe de musique ← « Chanteur ou groupe » (partiel).
- **Non couvertes** : Fleuve, Plante, Nourriture, Film, Personnage de conte, Matière scolaire, Maladie, Chanson.
→ Décision analogique : dictionnaire local distribué tel quel ; pour les catégories sans liste, validation locale = première lettre + longueur minimale (comportement maquette), marqué comme **provisoire** et listé dans `docs/RESTE_A_FAIRE.md`.

L'utilitaire `gameLogic.js` fournit de bonnes bases (normalisation NFD insensible casse/accents, filtrage de saisie `lettres/accents/espaces/tirets/apostrophes`, Prénom souple ≥ 3 caractères, tirage sans répétition) : à **reprendre** (relecture faite) en Dart dans `lib/domain`.

## 5. Hiérarchie et divergences constatées (décision retenue)

| # | Divergence | Cahier | Maquette | **Décision retenue** (source de priorité) |
|---|---|---|---|---|
| 1 | Catégories obligatoires | 4 (Prénom, Ville, Animal, Objet) | 5 avec Pays | **Prompt §4 : 5 obligatoires, avec Pays.** |
| 2 | Mot réutilisé | refusé | 5 pts, conflit à trancher | **Prompt §4 : 5 pts** (policy `reuseWins`, provisoire, badge « Règle à trancher ») |
| 3 | Solo et bonus 15 | §21 : « à valider » ; bonus si ≥ 2 joueurs | bonus aussi en solo | **Prompt §4 : 15 pts aussi en solo** |
| 4 | Lettres du tirage | A–Z sauf K W X Y Z (option) | pool `ABCDEFGHIJLMNOPRSTUV` (exclut aussi Q) | **Prompt §6 : seuls K W X Y Z exclus par défaut ; Q inclus**. Divergence maquette consignée |
| 5 | STOP avec chrono | §21 : à valider | réservé sans chrono | **Prompt §4 : STOP réservé au sans-chrono** (provisoire) |
| 6 | Nombre de manches | non borné | 1–5 | **Prompt §4 : 1–5 (borne provisoire)** |
| 7 | Catégories aléatoires | « nombre prévu » | socle + 4 | **Prompt §4 : +4 (nombre provisoire)** |
| 8 | Modes « même téléphone », « équipes » | §6.2, §5.2 | absents | Hors périmètre des phases 1–8 ; évalués à la phase 9 avec synthèse |
| 9 | EF-02 absente du cahier | saut EF-01 → EF-03 | — | Traiter « choix mode/catégories/durée » comme exigence EF-02 dans la traçabilité |
| 10 | Classement global | absent | overlay : « non disponible » | Bouton `Classement` du menu → **historique/meilleurs scores personnels** ; pas de classement global tant qu'il n'y a pas de serveur pour ça |

## 6. Risques

1. **Conflit de règles 15/10 vs réutilisé 5** : politique `ConflictPolicy` unique (`reuseWins` par défaut, provisoire), badge visuel, signalé dans le compte rendu final. (Impératif §5 du prompt.)
2. **Couverture du dictionnaire incomplète** pour 8 catégories optionnelles → refus possibles. Atténuation : validation souple pour ces catégories (marqué provisoire), enrichissement + cache des verdicts côté serveur plus tard.
3. **Android SDK absent** (`flutter doctor` ✗) et **iOS impossible** (Windows) : installation du SDK Android via `cmdline-tools.zip` (déjà dans Downloads) + licences à faire ; tests d'intégration exécutables sur Android une fois l'émulateur prêt, sinon documentés comme non exécutés. **Rien ne sera déclaré « testé » sans exécution réelle.**
4. **Polices woff2** (Flutter exige TTF) : conversion woff2→ttf (fontTools) ou récupération des TTF officiels du projet Google Fonts — à faire à la phase 1, avec vérification du rendu (golden tests).
5. **Figma = image statique** : la fidélité visuelle sera évaluée par comparaison aux captures ; animations issues de la maquette HTML (durées relevées : logo 70 ms/décalage, roue 3,4 s cubic-bezier(.12,.75,.1,1), alerte 0,5 s alternée, podium 0,8 s/gradin, confettis 3 s, compteurs 0,9 s ease-out).
6. **Firebase sans projet réel** : tout sera développé contre l'émulateur ; configuration du vrai projet documentée dans `docs/FIREBASE.md` (aucun secret dans le dépôt).
7. **node_modules du prototype** : exclu de la réutilisation (lecture seule, copie non faite). Seules `wordLists.js`, `letters.js`, `gameLogic.js` (portions reluées) sont reprises.

## 7. Environnement constaté (2026-10-24)

- Flutter 3.47.7 stable (`C:\dev\flutter`), Dart 3.13.5 — ✅
- Chrome / Edge — ✅ (appareil de test possible en web)
- Android toolchain — ❌ SDK introuvable (`cmdline-tools.zip` disponible dans Downloads ; `ANDROID_HOME` vide)
- Visual Studio Build Tools 2019 — incomplet (desktop Windows non ciblé)
- Git — ✅ ; dépôt de mission : `C:\Users\Zbook\Wordstorm` (branch `main`, remote `origin/main`, propre)
- Détails à mettre à jour dans `docs/ENVIRONNEMENT.md` (phase 1)

## 8. Questions ouvertes → `docs/QUESTIONS.md`

1. Conflit réutilisation (5 pts) × bonus (10/15) — application provisoire `reuseWins`.
2. Couverture du dictionnaire pour les 8 catégories optionnelles.
3. Lieu du dépôt : repo existant `C:\Users\Zbook\Wordstorm` retenu ; si un autre chemin était prévu, me le dire.
4. Mode « même téléphone » conservé ou non (cahier §21).
5. Instauration du mode équipes (hors périmètre du socle).

---

## Annexe — extraits clés relevés (référence implémentation)

- Palette maquette : `--y:#FFB703 --r:#FF5A5F --t:#2EC4B6 --n:#1E2A44 --w:#F4F7FB --g:#8B9BB4 --v:#7B61FF` ; verts de validation `#2FD18A` / `#1fbf74` ; dégradés des boutons : `.b` = `linear-gradient(#FFD25A,var(--c,#FFB703))` + ombre porte `0 6px 0 var(--d)` ; tuile lettre : `linear-gradient(135deg,#FFE27A,#FFB703 60%,#F29A00)` + ombres `0 7px 0 #C98300, 5px 8px 0 #A86F00`.
- Glyphes d'icônes SVG présents : user, users, gear, trophy, copy, crown, bolt, check, lock, paw, job, city, box, ball, fruit, warn, clock, arrow, globe, wave, leaf, film, star, note, book.
- Durées DUR = `[20,30,45,60,90,120,0]` (0 = sans chrono) ; label 20 s « · Speed ».
- Roue : 3,4 s, décélération `cubic-bezier(.12,.75,.1,1)`, +1440° avant arrêt, pointeur pivot, anneau central bleu-nuit.
- Chrono : anneau SVG r=37, `stroke-dasharray 232`, offset proportionnel au temps, passage rouge `#FF5A5F` + pulsation 0,5 s ≤ 10 s, bip ≤ 5 s.
- Saisie : chars autorisés `[^A-Za-zÀ-ÿ '\-]`, `capitalize`, `enterkeyhint next/done`, coche verte au remplissage, progression « n / N réponses ».
- STOP : grisé tant que toutes les catégories ne sont pas cochées (sans chrono uniquement).
