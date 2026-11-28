# Compte Rendu de la Session de Brainstorming — StageFlow M1 à M5

**Session** : du 26/11/2026 13h09 au 27/11/2026 13h01 (horaires OpenRouter)
**Agent** : Mary, agent Analyste (/bmad-agent-analyst)
**Participant** : Ikram (Product Owner)
**Périmètre** : Modules M1 à M5 (M6 hors périmètre)
**Méthode** : session menée question par question ; pour chaque question l'agent a proposé des options et une recommandation, la Product Owner a tranché.

---

## 1. Décisions Fonctionnelles Validées

### M1 — Identités et Droits

#### 1.1 Matrice de visibilité et d'action (7 catégories de ressources, 6 acteurs)
| Acteur | Offres | Candidatures | Conventions | Rapports | Évaluations tuteur | Utilisateurs/Affectations/Disponibilités | Configuration |
|--------|--------|--------------|-------------|----------|-------------------|------------------------------------------|-----------------|
| Étudiant | L (publiées) | L,C,M,S (siennes) | L,Sig (étape 1) | L,C,M,S* | L (son évaluation) | L,M (son profil) | — |
| Tuteur | L,C,M (ses offres) | L,V (sur ses offres) | L,Sig (étape 2) | L (ses stagiaires) | L,C,M,V (ses évaluations) | L,M (son profil) | — |
| Encadrant | L (liées) | L (ses étudiants) | L (ses étudiants) | L,V (ses étudiants) | L (ses étudiants) | L,M,C (indisponibilités) | L |
| Resp. filière | L,V (sa filière) | L (sa filière) | L,V,Sig (étape 3) | Lm ; L contenu* (selon besoin, voir question 1.1.8) | Lm ; L contenu* (selon besoin, voir question 1.1.8) | L,C,M,V (affectations) | L,M (sa filière) |
| Scolarité | L | L | L (archivage/PV) | Lm | Lm | L,C,M,S* (comptes) | L,M (étab.) |
| Admin | L,C,M,S* | L,S* | L,C,M,S* | Lm,S* | Lm,S* | L,C,M,S*,V (rôles) | L,C,M,S,V |

> **L**=Lecture, **C**=Création, **M**=Modification, **S**=Suppression, **V**=Validation, **Sig**=Signature, **Lm**=Lecture métadonnées, **S***=Purge technique

**Règles transverses** :
- Pas de suppression métier (archivage/anonymisation seulement)
- Journal d'audit sur actions sensibles
- Données fictives en dev/test
- Séparation technique/métier : Admin/Scolarité = métadonnées par défaut

Le représentant de l'établissement (signature étape 4) n'apparaît pas dans le tableau car son statut est ouvert (questions 1.1.7 et 3.1.5).

**Question 1.1.8** : Responsable de filière : l'accès au contenu intégral des rapports et des évaluations est-il nécessaire, ou les métadonnées et statuts suffisent-ils ?

#### 1.2 Gestion multi-rôles (Option A — Rôle unique actif)
- Utilisateur possède plusieurs rôles, agit dans un seul contexte à la fois
- Changement explicite via UI, vérification backend (rôle actif + permissions + lien ressource)
- Audit : `user_id`, `active_role`, `action`, `ressource`
- Session persistante, changeable à tout moment
- Refus si rôle non autorisé ou contexte invalide
- **Dédoublonnage notifications** : une seule notification par utilisateur/événement même si multi-rôles

---

### M2 — Offres et Candidatures

#### 2.1 Cycle de vie offre (machine d'états)
```
BROUILLON → PUBLIÉE → POURVUE
    ↑         │          │
    └─────────┴──────────┘
         (retours contrôlés)
```
- `BROUILLON → PUBLIÉE` : Tuteur publie, validation sujet Resp. filière si requise
- `PUBLIÉE → BROUILLON` : Si 0 candidature (pas de délai fixe)
- `PUBLIÉE → POURVUE` : Sélection + confirmation étudiante
- `PUBLIÉE → CLOSE` : Clôture sans sélection
- `POURVUE → PUBLIÉE` : Désistement avant convention + val. Resp. filière
- `CLOSE → PUBLIÉE` : Réouverture justifiée + Resp. filière
- Pas de suppression (archivage) ; Pas de modif libre publiée ; Traçabilité

#### 2.2 Candidatures
- **Pièces** : CV PDF obligatoire + Lettre si `offre.lettre_requise` + Notes optionnel ; PDF 5Mo/3 fichiers max
- **Modification** : Jusqu'à `CONSULTEE` ou sélection (si depuis `DEPOSEE`) → figé après
- **Retrait** : Possible si offre `PUBLIÉE` + notification tuteur
- **Cycle** : `DEPOSEE` → `CONSULTEE` (optionnel) → `EN_ATTENTE_CONFIRMATION` → `SELECTIONNEE`/`REJETEE`/`RETIREE`/`EXPIREE`

#### 2.3 Sélection
- Tuteur sélectionne **1 seul** candidat à la fois
- Étudiant : **Accepter / Refuser** (boutons explicites)
- Délai **48h** défaut (paramétrable établissement) + relance J+24h
- **Silence = refus implicite** → `REJETEE`, tuteur notifié
- **Retrait auto autres candidatures** = immédiat à l'acceptation → `RETIREE`
- **Désistement après acceptation** autorisé **avant signature convention**

---

### M3 — Conventions

#### 3.1 Circuit signatures (4 étapes, ordre imposé)
**États** : `GÉNÉRÉE` → `À_SIGNER_ETUDIANT` → `SIGNÉE_ETUDIANT` → `À_SIGNER_ENTREPRISE` → `SIGNÉE_ENTREPRISE` → `À_SIGNER_FILIÈRE` → `SIGNÉE_FILIÈRE` → `À_SIGNER_ÉTABLISSEMENT` → `SIGNÉE_FINALE` (+ `REJETÉE_X` par signataire)

**Règles** :
- Ordre strict : Étudiant → Entreprise → Filière → Établissement
- Demande correction : signataire X avant signature X+1, motif obligatoire → invalide signatures X+1...N
- Refus distinct de correction, motif obligatoire, notifié
- Historique immuable : versions successives + actions tracées, archivage après 4ème signature
- Génération PDF à `GÉNÉRÉE`, régénéré à chaque correction

#### 3.2 Relances (ossature validée, paramètres numériques **ouverts** — Q 3.2.1)
**4 profils** (valeurs = propositions non validées) :
- Étudiant : J+2, fréquence 2j, max 4
- Entreprise : J+3, fréquence 3j, max 3
- Resp. filière : J+5, fréquence 5j, max 2
- Établissement : J+7, fréquence 7j, max 2

**Escalade** : Scolarité unique destinataire après max relances (Q 3.2.4)
**Relance manuelle** : Resp. filière + Scolarité (étapes 1-3), Scolarité (étape 4) ; notifie signataire, journal « manuelle » (Q 3.2.5)
**Canaux** : Email + In-app ; Arrêt à signature / rejet / annulation
**Valeurs fixes** (pas paramétrage établissement M1-M5) (Q 3.2.1)
**Droit « Relancer »** à intégrer matrice 1.1 (Q 3.2.2)
**Copies (CC)** : systématiques ? destinataires exacts ? (Q 3.2.3)

#### 3.3 Avenants
- Déclencheurs (liste fermée) : dates, tuteur, sujet, entreprise, encadrant, filière
- Circuit : identique convention (4 signatures, même ordre)
- Relation : avenant complète convention initiale (ne remplace pas)
- Versioning : nouveau PDF, versions précédentes conservées
- Pas de limite nombre ; possible pendant le stage
- Notifications/relances = principes 3.2
- Corrections mineures sans avenant si 0 signature (régénération PDF tracée)

#### 3.4 Génération PDF / Template
1. Template unique, validé Scolarité (contenu) + Autorité établissement (conformité), versionné
2. Génération à chaque signature/correction, versions jamais écrasées
3. Traçabilité : signataire + date + version exacte ; version finale = 4 signatures
4. Archivage intégral (toutes versions)
5. Données minimales : étudiant, établissement, entreprise, tuteur, sujet, dates, lieu, encadrant, filière, infos signature ; **Identifiants entreprise : contexte marocain (ICE, RC, IF)**
6. Mentions légales validées établissement, conformes loi 09-08, **RGPD non supposé automatique**

---

### M4 — Suivi et Rapports

#### 4.1 Journaux (séparation validée)
**Journal suivi métier** : événements parcours stage + actions sensibles. Granularité : acteur, action, date, ressource, avant/après. Visibilité = matrice 1.1.

**Journal sécurité** : connexions, échecs auth, refus accès, changements rôles, exports, anomalies. Données techniques (IP, etc.) limitées/protegées. Accès réservé (acteurs habilités à définir).

**Séparation** : Journaux techniques (diagnostic/perf) distincts. Conformité loi 09-08 : pas données perso inutiles journal métier ; données techniques protégées journal sécurité ; durées conservation, anonymisation, acteurs sécurité = à confirmer établissement.

#### 4.2 Rapports versionnés
**Cycle** : Dépôt (étudiant) → Validation (encadrant) → Évaluation (tuteur) → Archivage.
**Versioning immuable** : chaque dépôt = nouvelle version (v1, v2...). Validée = figée. Versions précédentes conservées.
**Validation** : OK (verrouille) ou REFUS (commentaire obligatoire → nouveau dépôt v+1). Version refusée conservée.
**Évaluation** : Après validation seulement. Formulaire structuré : critères + note + commentaire. Critères/visibilité = ouverts.
**Historique** : toutes versions + décisions conservées. Journal métier (4.1) trace tout. Visibilité = matrice 1.1.

#### 4.3 Journal de stage pédagogique
1. Contenu : entrées datées (activités, apprentissages, difficultés). Durée = optionnelle établissement.
2. Fréquence : hebdomadaire proposée (à confirmer).
3. Suivi partagé : tuteur (pro) + encadrant (pédago). **Double validation formelle + ordre = ouvert**.
4. Historique traçable, versioning/validation précises = ouvertes.
5. Lien rapport : réutilisation manuelle par étudiant, pré-remplissage auto non imposé.
6. Lien évaluation : journal consultable par tuteur comme élément complémentaire.
7. Visibilité = matrice 1.1. **Distinct** journal métier/audit (4.1) et journal sécurité (4.1).

---

### M5 — Notifications et Tableau de Bord

#### 5.1 Règles notification
**Modèle unifié 4 criticités** : Critique, Importante, Information, Système. Liste exhaustive = Q 5.1.1.

**Routage par criticité (défaut)** (Q 5.1.2 pour routage précis) :
- Critique/Importante = WebSocket + Email
- Information = WebSocket (+ digest Email optionnel)
- Système = Email ciblé

**Préférences** : par acteur, par criticité, Email ON/OFF (WebSocket toujours ON si connecté). Critique = non désactivable. Granularité = Q 5.1.3.

**Persistance** : entité `Notification` (lu/non lu, archivable). Durée conservation = Q 5.1.4.

**Continuité** : WebSocket déconnecté → rattrapage à la reconnexion (since `last_seen`).

**Echecs email** : retry (nombre, fréquence, alerte Admin = Q 5.1.5).

**Digest** : optionnel Information (8h00). Critique/Importante jamais différées. Activation/horaires = Q 5.1.6.

**Cohérence 1.2** : Destinataire = rôles attribués + responsabilités + lien ressource. Rôle actif = contexte UI, **ne filtre pas** notifications. **Dédoublonnage** : une seule notification par utilisateur/événement même si multi-rôles (Q 5.1.7).

#### 5.2 Indicateurs tableau de bord

| Indicateur | Formule |
|------------|---------|
| **Taux placement** | Convention signée définitivement / Étudiants éligibles (promo) |
| **Délais signature** | Durée entre lancement circuit et 4ème signature **sur conventions finalisées** |
| **Charge encadrants** | NB étudiants affectés / encadrant |

Filtres : établissement, filière, promotion (pour les trois indicateurs). Visibilité : encadrant = sa charge ; responsable de filière = sa filière ; scolarité et administrateur = établissement.

**Règles** :
- Actualisation quotidienne (mécanisme technique hors PRD)
- **Historique des valeurs successives conservé pour suivi évolution**
- Export/Seuils alertes/Destinataires alertes = ouverts

---

## 2. Hypothèses Conservées

Les éléments suivants ont été formulés comme **hypothèses de travail** durant le brainstorming mais n'ont pas été validés comme décisions fermes. Ils restent à confirmer ou à infirmer lors des ateliers de décision ultérieurs :

| Module | Hypothèse | Statut |
|--------|-----------|--------|
| M1 | Relations métier gérées en PostgreSQL, pas dans Keycloak | Hypothèse technique |
| M1 | `user_context` par session applicative avec cookie HttpOnly | Hypothèse technique |
| M1 | `roles_version` sur utilisateur pour détection modifs admin | Hypothèse technique |
| M2 | Validation sujet Resp. filière = systématique ou selon filière | Question ouverte 2.1.1 |

---

## 3. Questions Ouvertes (65 au total)

### M1 — Identités et Droits (8 questions)
| ID | Question |
|----|----------|
| **1.1.1** | Étudiant : voit-il les offres *brouillon* de son établissement ? |
| **1.1.2** | Tuteur : modification offre *publiée* (correction mineure) autorisée ? |
| **1.1.3** | Encadrant : « si nécessaire au suivi » — qui juge ? (Auto-déclaration ? Validation resp. filière ?) |
| **1.1.4** | Scolarité : accès au **contenu** des rapports/évaluations pour PV ? (Métadonnées = validé) |
| **1.1.5** | Admin : accès au **contenu** des rapports/conventions/évaluations sur justification ? (Métadonnées = validé) |
| **1.1.6** | Entreprise multi-utilisateurs : plusieurs users/entreprise ? Rôle `ENTREPRISE` + `entreprise_id` partagé ? |
| **1.1.7** | Représentant établissement (signature étape 4) : acteur existant ou rôle distinct ? [= M3.1.5] |
| **1.1.8** | Responsable de filière : l'accès au contenu intégral des rapports et des évaluations est-il nécessaire, ou les métadonnées et statuts suffisent-ils ? |

### M2 — Offres et Candidatures (8 questions)
| ID | Question |
|----|----------|
| **2.1.1** | Validation sujet Resp. filière : systématique ou selon filière/type offre ? |
| **2.1.5** | Justification réouverture `CLOSE → PUBLIÉE` : format, liste, approbation ? |
| **2.1.6** | Notifications M2 générales : quelles transitions notifient qui ? |
| **2.2.1** | Conditions `EXPIREE` exactes (offre `CLOSE` vs `POURVUE`, sélectionnée ailleurs ?) |
| **2.2.2** | Déclencheur `CONSULTEE` : 1er GET ? Action explicite ? Les deux ? |
| **2.2.3** | Étudiant notifié à `CONSULTEE` / `SELECTIONNEE` / `REJETEE` / `EXPIREE` ? |
| **2.3.1** | Candidats `RETIREE` auto : recontactables / réactivables si désistement sélectionné ? |
| **2.3.2** | Désistement après acceptation : état candidature, réouverture offre, sort autres `RETIREE` ? |

### M3 — Conventions (17 questions)
| ID | Question |
|----|----------|
| **3.1.1** | Responsable correction selon nature erreur (étudiant, tuteur, resp. filière, scolarité) ? |
| **3.1.3** | Conséquences refus signature : convention bloquée ? retour `GÉNÉRÉE` ? nouvelle version ? qui relance ? impact offre/candidature ? |
| **3.1.4** | Notifications/relances (voir 3.2) ? |
| **3.1.5** | Représentant établissement (signature étape 4) : acteur existant ou rôle distinct ? [= 1.1.7] |
| **3.2.1** | Valeurs numériques exactes relances (J+X, fréquences, max) pour les 4 profils ? |
| **3.2.2** | Droit « Relancer » intégré explicitement dans matrice 1.1 (Resp. filière + Scolarité) ? |
| **3.2.3** | Copies (CC) : systématiques sur chaque relance ? Destinataires exacts par étape validés ? |
| **3.2.4** | Escalade : **Scolarité unique destinataire** — validé ? |
| **3.2.5** | Relance manuelle : notification signataire + type « manuelle » dans journal — validé ? |
| **3.3.1** | Correction formelle après 1ère signature : avenant obligatoire ou procédure 3.1 ? |
| **3.3.2** | Date limite avenant : fin effective stage, dépôt rapport, ou établissement PV soutenance ? |
| **3.3.3** | Refus avenant : traitement convention initiale + avenants en cours ? |
| **3.4.1** | Mécanisme de signature accepté : électronique, manuscrite numérisée, autre reconnu ? |
| **3.4.2** | Nécessité / faisabilité **signature électronique qualifiée eIDAS** ? |
| **3.4.3** | Liste exacte champs obligatoires dans le PDF (confirmation établissement) ? |
| **3.4.4** | Contenu mentions légales + durée conservation documentaire ? |
| **3.4.5** | Validation template officiel : responsables identifiés (Scolarité + Autorité) ? |

### M4 — Suivi et Rapports (20 questions)
| ID | Question |
|----|----------|
| **4.1.1** | Durée de conservation exacte de chaque journal (métier, sécurité) ? |
| **4.1.2** | Acteurs autorisés à consulter le journal de sécurité ? |
| **4.1.3** | Niveau de détail données connexion (IP, user_agent...) dans journal sécurité et protection ? |
| **4.1.4** | Liste définitive événements métier à tracer ? |
| **4.1.5** | Modalités consultation/export journaux (UI, API, format, traçabilité export) ? |
| **4.1.6** | Règles d'anonymisation/suppression à expiration durées conservation ? |
| **4.2.1** | Formats autorisés, taille max, métadonnées obligatoires du dépôt ? |
| **4.2.2** | Critères et barème de l'évaluation tuteur ? |
| **4.2.3** | Visibilité de l'évaluation selon les acteurs ? |
| **4.2.4** | Notifications à chaque dépôt, validation, refus, évaluation ? |
| **4.2.5** | Conditions d'une nouvelle version **après évaluation** ? |
| **4.2.6** | Moment et conditions de l'archivage définitif ? |
| **4.2.7** | Droit tuteur « Évaluer » à ajouter explicitement dans matrice 1.1 ? |
| **4.3.1** | Champs obligatoires et modèle du journal (imposé par établissement) ? |
| **4.3.2** | Fréquence exacte des saisies (hebdomadaire confirmée ?) ? |
| **4.3.3** | Validation obligatoire ou simple consultation par tuteur et encadrant ? Si validation : ordre et conséquences ? |
| **4.3.4** | Règles de modification des entrées et historique (versioning comme rapports ?) ? |
| **4.3.5** | Pièces jointes autorisées dans le journal ? |
| **4.3.6** | Modalités de réutilisation des entrées dans le rapport (export manuel ? pré-remplissage optionnel ?) ? |
| **4.3.7** | Archival du journal : moment, durée, format ? |

### M5 — Notifications et Tableau de Bord (12 questions)
| ID | Question |
|----|----------|
| **5.1.1** | Liste exhaustive événements par domaine (M2, M3, M4) et leur criticité ? |
| **5.1.2** | Routage précis par événement et par canal (confirmation/adaptation règle par défaut) ? |
| **5.1.3** | Granularité préférences utilisateur et exceptions obligatoires (Critique non désactivable) ? |
| **5.1.4** | Durée de conservation notifications et règles d'archivage ? |
| **5.1.5** | Modalités retry email (nombre, fréquence, alerte Admin) ? |
| **5.1.6** | Activation/horaires digest quotidien (Information uniquement) ? |
| **5.1.7** | Règles notification utilisateurs multi-rôles (cohérence 1.2 + dédoublonnage) ? |
| **5.2.1** | Définition exacte des **étudiants éligibles** au taux de placement ? |
| **5.2.2** | Délais signature : **jours calendaires** ou **jours ouvrés** ? |
| **5.2.3** | **Export** : formats (CSV/PDF/Excel), acteurs autorisés ? |
| **5.2.4** | **Seuils d'alerte/performance** — à confirmer établissement ? |
| **5.2.5** | **Alertes** : destinataires, criticité (5.1), déclencheur ? |

**Total : 8 + 8 + 17 + 20 + 12 = 65 questions ouvertes** (dont 1 doublon : 1.1.7 = 3.1.5, et 1 renvoi : 3.1.4)

---

## 4. Distinction Claire : Exigences Cahier / Décisions / Hors Périmètre

| Catégorie | Contenu |
|-----------|---------|
| **[CAHIER]** | Exigences explicites du cahier des charges : 6 acteurs, 4 états offre, circuit 4 signatures, journal suivi, dépôt versionné, validation encadrant, évaluation tuteur, notifications WS+Email, 3 indicateurs, stack imposée (Java 21, Spring Boot 3, React 18, PostgreSQL 16, Keycloak, Docker, GitHub Actions, SonarQube), sécurité, traçabilité, loi 09-08, performance (<500ms P95, planning <60s), qualité (SonarQube, couverture ≥70%) |
| **[DÉCISION]** | Choix fonctionnels validés en brainstorming (matrice 1.1 complète, rôle unique actif, machines d'états M2/M3, cycle rapports, journaux séparés, modèle notification 4 criticités, formules indicateurs, etc.) — listées exhaustivement dans la section 1 |
| **[QUESTION OUVERTE]** | 65 questions identifiées et formulées précisément par module (M1:8, M2:8, M3:17, M4:20, M5:12) — conservées sans résolution |
| **[HORS PÉRIMÈTRE BRAINSTORMING FONCTIONNEL]** | Choix techniques d'implémentation : batch 02h00 vs vues matérialisées vs cache ; stockage PDF (S3 vs BD) ; mécanisme signature (eIDAS vs autre) ; partitionnement tables ; framework WebSocket ; algorithmes calcul ; CI/CD ; **détails techniques M1.2 (PostgreSQL, cookie HttpOnly, `roles_version`, révocation Keycloak)** ; etc. |


**Fin du compte rendu — Brainstorming M1–M5 clos.**