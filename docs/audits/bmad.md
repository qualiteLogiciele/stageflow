# Audit : BMAD Method

- Date : 25 novembre 2026
- Auteur : Ikram (Product Owner)
- Outil : BMAD Method (paquet npm `bmad-method`)
- Version retenue : 6.12.4 (publiée le 14 octobre 2026)
- Raison du choix : dernière version stable, publiée depuis plus de six semaines ; l'enseignant n'a pas figé de version

## Ce qui a été vérifié
- Licence : MIT
- Dépôt source : https://github.com/bmad-code-org/BMAD-METHOD (même adresse que celle déclarée par npm)
- Scripts d'installation : aucun script preinstall, install ou postinstall ; un seul script automatique, `prepare`, qui ne fait rien si l'outil husky est absent ; les autres scripts sont des outils de développement (tests, lint, documentation)
- Dépendances : bibliothèques courantes (glob, yaml, chalk, commander, semver, xml2js, js-yaml, csv-parse, picocolors, @clack/prompts, @clack/core, ignore, @kayvan/markdown-tree-parser)

## Ce qui sera vérifié après installation
- Liste des fichiers et dossiers ajoutés au dépôt (git status)
- Absence de secret ou de clé dans ces fichiers

## Conclusion
Aucun élément inquiétant constaté. Installation autorisée pour l'équipe, en version 6.12.4.

## Vérification après installation (25 novembre 2026)
- Installation : `npx bmad-method@6.12.4 install --modules bmm --tools opencode`
- Dossiers ajoutés au dépôt : `_bmad/` (agents, workflows, configuration), `.agents/` (skills pour OpenCode), `.opencode/commands/` (commandes OpenCode)
- Taille totale : environ 2,6 Mo
- Recherche de la chaîne `sk-or-` dans le dépôt : aucun résultat, aucune clé présente
- Avertissement npm constaté à l'installation : la dépendance `glob@11.1.0` est signalée comme dépréciée ; sans impact sur l'installation, point de vigilance
- Message de l'installateur sur BMad v7 (bêta) : non utilisé, le groupe reste sur la version 6.12.4
