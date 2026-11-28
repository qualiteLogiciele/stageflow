# Modèle de critères d'acceptation

Les critères d'acceptation des stories sont écrits sous forme de scénarios
Cucumber, au même format que les scénarios publics de l'annexe A.4.
Ils doivent être vérifiables (§1) et couverts par des tests (§5.2 règle 2).

## Format

~~~gherkin
# language: fr
Fonctionnalité: <nom de la fonctionnalité>

  Scénario: <comportement attendu>
    Étant donné <situation de départ>
    Quand <action>
    Alors <résultat vérifiable>
~~~

## Exemple tiré de l'énoncé (annexe A.4)

~~~gherkin
# language: fr
Fonctionnalité: Planification des soutenances

  Scénario: Un enseignant indisponible n'est jamais convoqué
    Étant donné que "Pr. Bennani" est indisponible le "mardi" de 8h à 12h
    Quand le responsable lance la planification de la session "Juin"
    Alors "Pr. Bennani" n'a aucune soutenance le "mardi" de 8h à 12h
~~~

## Rappels de l'énoncé
- Données fictives uniquement (§2.4, §11)
- Un scénario fourni par l'enseignant n'est jamais modifié (§11)
