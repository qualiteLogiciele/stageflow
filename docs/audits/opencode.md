# Audit : OpenCode

- Date : 26 novembre 2026
- Auteur : Asmae (Responsable DevOps et sécurité)
- Outil : OpenCode, assistant de code du groupe (paquet npm `opencode-ai`)
- Version retenue : 1.19.5 (même version que celle déjà utilisée dans l'équipe ; le guide OpenRouter a été vérifié avec 1.19.4)
- Installation prévue : `npm install -g opencode-ai@1.19.5`

## Ce qui a été vérifié avant installation (registre npm, version 1.19.5)
- Licence : MIT
- Mainteneur du paquet : thdxr (équipe OpenCode)
- Dépôt source : non déclaré dans les métadonnées npm de cette version — à confirmer : https://github.com/sst/opencode (site officiel : https://opencode.ai)
- Dépendances : aucune dépendance directe
- Dépendances optionnelles : uniquement les binaires précompilés par plateforme, à la même version
  (`opencode-windows-x64`, `opencode-linux-x64`, `opencode-darwin-arm64`, etc.) ; npm n'installe que celui de la machine
- Scripts automatiques : pas de `preinstall` ni d'`install` ; un `postinstall` : `node ./postinstall.mjs`
  → point de vigilance : lire ce fichier dans le paquet avant d'installer
  (`npm pack opencode-ai@1.19.5` puis ouvrir `package/postinstall.mjs`)
- Commande exécutable : `opencode` (binaire `bin/opencode.exe`)

## Configuration du projet
- `opencode.json` versionné à la racine : fixe `model` et `small_model` sur des modèles `:free` d'OpenRouter
- Aucun secret dans `opencode.json` ; la clé est lue depuis la variable d'environnement `OPENROUTER_API_KEY`
- Routeur `openrouter/free` non utilisé (le modèle doit rester le même pour toute la pipeline 2)

## Données envoyées
- Tout le contenu envoyé au modèle gratuit est journalisé par le fournisseur (NVIDIA) et peut servir à l'entraînement
- Règle du groupe : uniquement le code du projet et des données fictives ; jamais de clé, mot de passe ni donnée personnelle réelle

## Ce qui sera vérifié après installation
- [x] Contenu de `postinstall.mjs` lu (26/11/2026, via `npm pack opencode-ai@1.19.5`, hors du dépôt) : **aucun élément inquiétant**
  - Rôle : choisir et copier le binaire précompilé de la plateforme (`opencode-windows-x64` ou `-baseline`) vers `bin/opencode.exe`
  - Commandes lancées : PowerShell pour tester une capacité du processeur (AVX2, via `IsProcessorFeaturePresent` de kernel32) ;
    `sysctl` (macOS) et `ldd --version` (Linux) pour la même détection ; `opencode.exe --version` pour vérifier le binaire
  - Réseau : aucun `fetch`, `curl` ni adresse externe. Seul cas de téléchargement : si le binaire manque, un
    `npm install --ignore-scripts` du paquet de plateforme à la **même version épinglée**, depuis le registre npm, dans un dossier temporaire supprimé ensuite
  - Aucune lecture de variable d'environnement (donc pas d'accès à `OPENROUTER_API_KEY`), aucun fichier écrit hors du dossier du paquet et du dossier temporaire
- [x] `opencode --version` affiche 1.19.5 (installation : `added 3 packages`)
- [x] Fichiers ajoutés au dépôt par OpenCode (git status) : aucun ; seuls apparaissent les fichiers de configuration du groupe (`opencode.json` modifié, `.gitignore`, `.env.example`, `docs/`)
- [x] Recherche de `sk-or-` dans le dépôt (`git grep`) : aucun résultat ; fichiers non suivis contrôlés aussi : aucune clé (seule la mention textuelle du préfixe dans cet audit)
- [x] Requête de test visible dans Activity d'OpenRouter : modèle `nvidia/nemotron-3-ultra-550b-a55b:free`, application OpenCode, coût 0,00 $

## Conclusion
Aucun élément inquiétant constaté. Installation autorisée pour l'équipe, en version 1.19.5 (`npm install -g opencode-ai@1.19.5`).
