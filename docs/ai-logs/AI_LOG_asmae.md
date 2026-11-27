# AI_LOG — Asmae (Responsable DevOps et sécurité)

## 2026-11-26 — Séance 1 : configuration de l'environnement (≈ 11h00-11h55)
Assistant : OpenCode 1.19.5 — Modèle : openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
Étape : mise en place de l'environnement (hors cycle d'outil)

- Audit OpenCode : postinstall.mjs lu avant installation, aucun élément inquiétant (voir docs/audits/opencode.md)
- Compte OpenRouter : confidentialité réglée (free endpoints train + publish activés, ZDR désactivé)
- Incident sécurité : première clé affichée par erreur dans une conversation → révoquée immédiatement, nouvelle clé créée
- Clé API standard rangée en variable d'environnement utilisateur Windows (OPENROUTER_API_KEY), hors dépôt
- Installation : `npm install -g opencode-ai@1.19.5` → version 1.19.5 confirmée
- `opencode models` : nemotron-3-ultra-550b-a55b:free et nemotron-3.5-lightning:free disponibles
- Test `opencode run "Réponds seulement : OK"` : réponse OK, modèle nvidia/nemotron-3-ultra-550b-a55b:free
- Contrôles : `git grep "sk-or-"` sans résultat ; aucun fichier ajouté au dépôt par OpenCode
- Aide externe : opencode.json, .gitignore, .env.example et audit OpenCode préparés avec l'assistance de Claude (hors OpenCode), relus et validés par moi

- modele: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
- requetes_seance: 2          # lu sur la page Activity
- tokens_seance: 9.01K
- incidents_429: 1 (quota journalier free-models-per-day, fin de séance)
- attente_min: 0
- cout_seance: 0 $
- remarque : le quota de 50 req/jour est épuisé en une séance d'environ 1 h 30 avec 6 demandes (≈ 8,5 requêtes par demande) ; à signaler à l'équipe pour le choix de la formule

## 2026-11-26 — Séance 2 : stack Docker locale PostgreSQL + Keycloak (≈ 12h30-14h05)
Outil : BMAD 6.12.4 (/bmad-build) — Assistant : OpenCode 1.19.5 — Modèle : openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
Session OpenCode : « bmad-build skill setup » (relevée avec /sessions)
Étape du cycle : bmad-build (tâche d'infrastructure du jalon J1, avant le PRD)

Préalable :
- BMAD 6.12.4 récupéré depuis setup/bmad par fast-forward (aucun commit créé), audit docs/audits/bmad.md (Ikram) relu
- Vérification `/bmad-help` : OK avec Nemotron 3 Ultra (free), réponse en 49 s, en anglais malgré communication_language = French

Demandes à l'agent : 6 (dont 1 refusée pour quota)
1. `/bmad-build` : l'agent cherche des artefacts dans _bmad-output/ (aucun), puis demande quoi construire.
   Il lance des commandes Linux (`ls -la`) refusées par PowerShell, puis se corrige avec Get-ChildItem (4 commandes en échec)
2. Prompt de la tâche (fichiers, images versionnées, aucun secret en dur, healthcheck, ports, consigne PowerShell, aucun commit) :
   docker-compose.yml, docker/postgres/init/01-create-keycloak-db.sql, keycloak/realm/.gitkeep et .env.example créés.
   Toutes les contraintes respectées. BMAD n'a produit aucune spec ni artefact dans _bmad-output/ (tâche traitée directement)
3. Correction : remplacer KEYCLOAK_ADMIN / KEYCLOAK_ADMIN_PASSWORD (dépréciés depuis Keycloak 26) par
   KC_BOOTSTRAP_ADMIN_USERNAME / KC_BOOTSTRAP_ADMIN_PASSWORD.
   Régression introduite : docker-compose.yml lit encore ${KEYCLOAK_ADMIN} et ${KEYCLOAK_ADMIN_PASSWORD},
   alors que .env.example définit KC_BOOTSTRAP_ADMIN_USERNAME / KC_BOOTSTRAP_ADMIN_PASSWORD → admin Keycloak vide au démarrage
4. Correction de la régression (valeurs ${KC_BOOTSTRAP_ADMIN_USERNAME} / ${KC_BOOTSTRAP_ADMIN_PASSWORD}) :
   corrigée en 9 s, vérifiée par relecture du fichier — noms cohérents entre docker-compose.yml et .env.example

Interventions manuelles : 0 ligne modifiée à la main
Relecture : faite avec l'assistance de Claude (hors OpenCode) ; écarts repérés : variables dépréciées, puis incohérence des noms de variables
Tests (manuels, aucune demande à l'agent) :
- Docker Desktop lancé (premier essai en échec : moteur arrêté, erreur npipe dockerDesktopLinuxEngine)
- `.env` créé à partir de .env.example avec des valeurs fictives ; vérifié absent de `git status`
- `docker compose config` : variables résolues, noms Keycloak cohérents
- `docker compose up -d` : images téléchargées (~38 s), stageflow-postgres healthy, stageflow-keycloak démarré
- Logs Keycloak : version 26.0.8 démarrée en 18 s sur le port 8180 ; 148 change sets appliqués (base keycloak créée) ;
  « Created temporary admin user with username admin » → variables KC_BOOTSTRAP_* bien lues, aucun avertissement de dépréciation
- Avertissements notés, sans impact : « JDBC resources leaked » au premier démarrage, mode développement (start-dev attendu)
- Console d'administration http://localhost:8180 : connexion admin OK sur le realm master

Point relevé : l'étiquette d'image `26.0` a été résolue en 26.0.8 → épinglage demandé (demande 5)

Suite — CI minimale de sécurité (protection de main en attente des droits admin, accordés par Chaymae en cours de séance) :
5. `/bmad-build` + prompt groupé : épingler keycloak:26.0.8, créer .github/workflows/security.yml (gitleaks sur PR,
   push main et m6/**, permissions contents: read) et .github/dependabot.yml (github-actions + docker, hebdomadaire).
   Fichiers créés en 41 s, YAML valides, épinglage correct. Écarts repérés à la relecture :
   - Dependabot : écosystème "docker" (cherche des Dockerfile, absents) au lieu de "docker-compose"
   - Workflow : filtre pull_request `branches: ['*']` qui ne couvre pas les branches avec un / (ex. m6/speckit)
   - Workflow : permission pull-requests: read manquante pour gitleaks sur les PR ; commentaires à désactiver
6. Envoi des 3 corrections : refusé par OpenRouter — « Rate limit exceeded: free-models-per-day »
   (quota de 50 requêtes/jour de la formule gratuite atteint). Corrections reportées à la prochaine séance.
   Fichiers .github/ laissés en l'état (non commités).

Action manuelle (sans agent) : ruleset GitHub « protect-main » créé sur main (PR obligatoire avec 1 approbation,
force push et suppression bloqués), après passage en admin par Chaymae

- modele: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
- requetes_seance: 51 (journée : 53 sur Activity → Explore, dont 2 en séance 1)
- requetes_par_modele (journée) : Nemotron 3 Ultra 49, Nemotron 3.5 Lightning 4 (small_model : titres de sessions, tâches annexes)
- quota journalier de 50 atteint (formule gratuite)
- contexte_session: 19.7K tokens (2 %) au prompt principal, 22.2K tokens (2 %) après la correction
- incidents_429: 1 (quota journalier free-models-per-day, fin de séance)
- attente_min: 0
- cout_seance: 0 $
- remarque : le quota de 50 req/jour est épuisé en une séance d'environ 1 h 30 avec 6 demandes (≈ 8,5 requêtes par demande) ; à signaler à l'équipe pour le choix de la formule

## 2026-11-27 — Séance 3 : corrections CI de sécurité et préparation de la PR (≈ [9h23])
Outil : BMAD 6.12.4 (/bmad-build) — Assistant : OpenCode 1.19.5 — Modèle : openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
Session OpenCode : « bmad-build skill setup » (reprise de la séance 2 avec `opencode -c`)

Demandes à l'agent : 1
1. Renvoi des 3 corrections refusées la veille pour quota :
   - .github/dependabot.yml : écosystème "docker" → "docker-compose"
   - .github/workflows/security.yml : filtre `branches: ['*']` supprimé du déclencheur pull_request
   - .github/workflows/security.yml : permission `pull-requests: read` et `GITLEAKS_ENABLE_COMMENTS: false` ajoutées
   Résultat : les 3 corrections appliquées du premier coup, aucun autre fichier modifié ; YAML valides (vérification par relecture)

Interventions manuelles : 0 ligne modifiée à la main

- modele: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
- requetes_seance:            # lu sur la page Activity
- incidents_429: 0
- attente_min: 0
- cout_seance: 0 $
