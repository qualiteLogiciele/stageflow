# Definition of Done — StageFlow

Une story n'est **done** que si toutes les conditions ci-dessous sont remplies.
Chaque condition renvoie à la section de l'énoncé qui l'impose.

## Critères d'acceptation et tests
- [ ] La story a des critères d'acceptation vérifiables (§1, §5.1 Stories)
- [ ] Les critères sont couverts par des tests qui passent en CI (§5.2 règle 2)
- [ ] Les scénarios Cucumber correspondent aux critères d'acceptation (§5.1 Implémentation)
- [ ] Aucun scénario d'acceptation fourni par l'enseignant n'a été modifié (§11)

## Revue
- [ ] Une revue a été faite et un rapport de revue existe pour la story (§5.1 Revue, §5.2 règle 2)
- [ ] La story passe par une pull request relue par un membre humain, aucun commit direct sur main (§5.2 règle 3)
- [ ] Le statut dans le fichier de story correspond à la réalité du code (§5.2 règle 2, malus §10.1)

## Documentation
- [ ] Si l'architecture change, le document d'architecture change dans la même pull request (§5.2 règle 4)

## Qualité
- [ ] Quality gate SonarQube du cours respecté (§2.4, §8)
- [ ] Couverture des tests d'au moins 70 % sur le domaine et les services (§2.4)

## Sécurité et données
- [ ] Aucun accès à une donnée sans vérification du rôle et du lien avec la ressource (§2.4 Sécurité)
- [ ] Aucun secret dans le dépôt ni dans l'historique Git (§2.4, malus §10.1)
- [ ] Toute action sensible est journalisée : qui, quoi, quand, avant/après (§2.4 Traçabilité)
- [ ] Uniquement des données fictives, aucune donnée personnelle dans les journaux applicatifs (§2.4, §11)
