# AI_LOG — Hasnae

## 2026-11-02 — Installation initiale
- Compte OpenRouter, clé, confidentialité, OpenCode installés
- Modèle configuré : openrouter/cohere/north-mini-code:free

## 2026-11-21 — Changement de modèle
Assistant : OpenCode 1.19.5
- Incident : cohere/north-mini-code:free n'est plus disponible sur OpenRouter (erreur au lancement d'OpenCode)
- Incident : nvidia/nemotron-3-super-120b-a12b:free (exemple du guide) aussi indisponible (erreur 404)
- Vérification : clé OK (free tier, 50 req/jour), liste des modèles :free consultée
- Nouveau choix du groupe : nemotron-3-ultra-550b-a55b:free (model) + nemotron-3.5-lightning:free (small_model), en attente de validation prof
- Test OpenCode OK (coût 0 $)
- requetes_seance: ~5 | incidents_429: 0 | cout_seance: 0 $

## 2026-11-25 — Répartition des rôles
- Rôle attribué (tirage) : Responsable qualité
- Agents BMAD supervisés : QA, revue de code
- requetes_seance: 0 | cout_seance: 0 $

## 2026-11-28 — Rôle qualité : DoD, modèle de critères et AGENTS.md
- Création de docs/qualite/definition-of-done.md et template-criteres.md, basés uniquement sur l'énoncé (rédigés avec l'aide de Claude, relus par moi)
- Création de AGENTS.md : règles lues automatiquement par l'agent OpenCode (respect de la DoD, du modèle de critères, scénarios enseignant non modifiés, données fictives, pas de commit direct sur main)
- PR #4 ouverte pour validation par l'équipe
- requetes_seance: 0 | cout_seance: 0 $