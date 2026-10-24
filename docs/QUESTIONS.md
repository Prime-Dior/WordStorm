# QUESTIONS — décisions à trancher (avec comportement provisoire appliqué)

Conformément à la règle de conduite n°2 : chaque question est enregistrée ici, un comportement provisoire clairement marqué est appliqué, et le travail continue.

## Q1. Conflit de règles : réutilisation (5 pts) × bonus (10/15)
Un mot réutilisé peut aussi être « la seule réponse valide » (15) ou « valide unique » (10).
- **Provisoire appliqué** : `ConflictPolicy.reuseWins` → **5 pts** (seule valeur explicitement donnée), badge « Règle à trancher » dans les résultats, implémenté dans un seul point de configuration du moteur.
- **À trancher** : priorité réutilisation vs bonus. Voir prompt §5.

## Q2. Couverture du dictionnaire (8 catégories optionnelles non couvertes)
Fleuve, Plante, Nourriture, Film, Personnage de conte, Matière scolaire, Maladie, Chanson n'ont pas de liste dans le dictionnaire Petit Bac (2 226 mots, 18 catégories).
- **Provisoire appliqué** : validation par première lettre + longueur minimale (comportement de la maquette), marqué provisoire dans les résultats (« Dictionnaire local non disponible pour cette catégorie »).
- **À trancher** : enrichissement du dictionnaire (source, licence) ou vérification en ligne par Cloud Function.

## Q3. Emplacement du dépôt
Le dépôt existant `C:\Users\Zbook\Wordstorm` (remote `origin/main`) a été retenu comme dépôt de mission.
- **Provisoire appliqué** : travail sur branche `feature/app-complete` avec commits atomiques.
- **Me signaler** si le dépôt de destination devait être ailleurs.

## Q4. Mode « même téléphone » (cahier §21)
- **Provisoire appliqué** : non implémenté dans les phases 1–8 ; reconsidéré à la phase 9 (paliers 5.2/5.3 du cahier).

## Q5. Mode équipes (cahier §21, §5.2)
- **Provisoire appliqué** : hors périmètre du socle ; traitement des réponses identiques entre coéquipiers non défini. Reconsidéré à la phase 9.

## Q6. Critère de départage à égalité (cahier §21)
- **Provisoire appliqué** : égalité affichée sans départage (podium à deux co-numéro 1) ; à trancher plus tard (ex. manches gagnées, temps, tirage).

## Q7. Q inclus dans les lettres normales ?
La maquette exclut Q (pool `ABCDEFGHIJLMNOPRSTUV`), le prompt n'exclut que K W X Y Z.
- **Provisoire appliqué** : Q inclus (source prioritaire = décisions du prompt). Divergence consignée dans `docs/ANALYSE.md` §5-4.
