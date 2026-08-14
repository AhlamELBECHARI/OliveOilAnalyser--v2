# Olive IQ — OliveOilAnalyser

**Analyse de la qualité de l'huile d'olive par spectroscopie.**

- **Institution :** UM6P - Foundation Mascir
- **Auteur :** Ahlam EL BECHARI

## Structure du dépôt

- `backend/` — API Django REST Framework (voir ci-dessous)
- `frontend/` — application Flutter mobile-first (authentification, dashboard,
  module Bluetooth/acquisition, historique, modèles, alertes, profil — voir
  ci-dessous)
- `docs/` — diagrammes de conception et maquettes

## Documentation visuelle

- Diagrammes de conception : `docs/diagrams/`
- Maquettes de l'application : `docs/maquette/`

## Backend

## Stack

- Django + Django REST Framework (DRF)
- PostgreSQL (via `psycopg` v3)
- `djangorestframework-simplejwt` (JWT access + refresh, avec `token_blacklist` activé —
  aussi utilisé pour lister/révoquer les sessions actives d'un compte)
- Mots de passe hashés avec bcrypt (`BCryptSHA256PasswordHasher`)
- `Pillow` (photos de profil, servies depuis `MEDIA_ROOT` en développement)
- `django-cors-headers` (CORS ouvert uniquement quand `DEBUG` est actif, pour le build web Flutter)
- Migrations Django natives
- Docker + docker-compose (Django + PostgreSQL)
- `pytest-django` pour les tests
- `drf-spectacular` pour la documentation OpenAPI/Swagger (`/api/docs/`)

## Architecture

Chaque app suit la même séparation en couches :

```
models.py       -> ORM uniquement (aucune validation métier)
serializers.py  -> validation de format DRF
services.py     -> toute la logique métier (y compris les requêtes ORM)
views.py        -> vues minces, appellent uniquement services.py
urls.py         -> routes de l'app
```

Le package `core/` (pas une app Django, pas de modèles) centralise ce qui est
partagé entre apps :

- `core/permissions.py` — `IsAdministrateur`, `EstProprietaireOuAdministrateur` : permissions par rôle réutilisées dans toutes les vues concernées, jamais réécrites.
- `core/exceptions.py` — handler DRF qui uniformise les réponses d'erreur (400/401/403/404 gérés par DRF ; 409 pour une suppression bloquée par une contrainte `PROTECT`).
- `core/pagination.py` — pagination standard des listes.

### Apps

| App | Modèles | Endpoints |
|---|---|---|
| `comptes` | `Utilisateur`, `Configuration` | `/api/auth/*`, `/api/utilisateurs/`, `/api/utilisateurs/moi/`, `/api/configuration/` |
| `echantillons` | `Echantillon` | `/api/echantillons/` |
| `spectres` | `Spectre` | `/api/spectres/` |
| `modeles` | `Modele` | `/api/modeles/` |
| `resultats` | `Resultat` | `/api/resultats/` |
| `analyses` | *(aucun — agrège en lecture seule)* | `/api/analyses/historique/`, `/api/analyses/statistiques-rapides/`, `/api/analyses/export/` |
| `rapports` | `Rapport` | pas de CRUD direct ; créé par `POST /api/analyses/export/` |
| `alertes` | `Alerte` | `/api/alertes/` |
| `dashboard` | *(aucun — agrège en lecture seule)* | `/api/dashboard/statistiques/` |
| `administration` | `JournalAudit` | `/api/admin/supervision/`, `/api/admin/journal-audit/`, `/api/admin/donnees/statistiques/`, `/api/admin/donnees/purge/apercu/`, `/api/admin/donnees/purge/` |

`core/qualite.py` centralise la dérivation de la catégorie qualité
(EVOO/VOO/Lampante) à partir de l'acidité et des seuils de `Configuration` :
`dashboard` et `analyses` s'appuient tous les deux dessus, pour ne jamais
classer un même résultat différemment selon l'écran.

## Lancement avec Docker

```bash
cd backend
cp .env.example .env
docker compose up --build
```

Le conteneur `web` attend que PostgreSQL soit prêt, applique automatiquement
les migrations (`python manage.py migrate`) puis démarre le serveur de
développement sur [http://localhost:8000](http://localhost:8000).

Créer un compte administrateur (root) :

```bash
docker compose exec web python manage.py createsuperuser
```

## Migrations (hors Docker)

```bash
cd backend
python -m venv venv
source venv/bin/activate   # ou venv\Scripts\activate sous Windows
pip install -r requirements-dev.txt
cp .env.example .env       # ajuster POSTGRES_HOST=localhost si Postgres tourne en local
python manage.py migrate
```

## Documentation de l'API

Swagger UI est disponible sur **`/api/docs/`** une fois le serveur lancé
(schéma OpenAPI brut sur `/api/schema/`). C'est le point d'entrée recommandé
pour explorer et tester tous les endpoints (auth par bearer token JWT
directement depuis l'interface).

## Authentification et permissions

- `POST /api/auth/register/` — inscription publique. Le rôle est **toujours**
  forcé à `utilisateur` côté serveur, quoi que le client envoie dans la
  requête (`role`, `is_staff`, `is_superuser` sont ignorés).
- `POST /api/utilisateurs/administrateurs/` — crée un compte administrateur ;
  réservé aux administrateurs déjà authentifiés.
- `POST /api/auth/login/` — verrouille temporairement un compte après
  `MAX_TENTATIVES_ECHOUEES` échecs consécutifs (5 par défaut, pendant
  `DUREE_VERROUILLAGE_MINUTES` = 15 minutes) ; le compte se déverrouille
  automatiquement dès que cette date est dépassée, à la prochaine tentative
  de connexion.
- `POST /api/auth/refresh/` — rafraîchit un access token.
- `POST /api/auth/reset-password/` puis `POST /api/auth/reset-password/verify/`
  puis `POST /api/auth/reset-password/confirm/` — réinitialisation en trois
  temps (code à 6 chiffres). Seul un hash SHA-256 du code est stocké côté
  serveur (jamais le code en clair) ; en dev, l'email est affiché dans les
  logs du conteneur `web` (backend console). À la confirmation, tous les
  refresh tokens existants de l'utilisateur sont blacklistés
  (`rest_framework_simplejwt.token_blacklist`).
- `GET /api/utilisateurs/` et `GET`/`PUT /api/configuration/` — réservés aux
  administrateurs (`core.permissions.IsAdministrateur`).
- `GET`/`PATCH /api/utilisateurs/moi/` — un utilisateur consulte et modifie
  son propre profil (nom, téléphone, fonction, laboratoire, institution,
  photo). `role`, `is_staff` et `is_superuser` ne sont jamais acceptés en
  entrée : structurellement impossible de s'auto-élever de rôle par cet
  endpoint.
- `POST /api/auth/changer-mot-de-passe/` — vérifie l'ancien mot de passe puis
  blackliste tous les refresh tokens en circulation pour ce compte (même
  portée de sécurité qu'une réinitialisation).
- `GET /api/auth/sessions/` et `DELETE /api/auth/sessions/<id>/` — sessions
  actives = refresh tokens émis (`OutstandingToken`) ni blacklistés ni
  expirés ; permet de révoquer une session précise à distance.
- `/api/echantillons/`, `/api/spectres/`, `/api/resultats/` — CRUD ouvert à
  tout utilisateur authentifié, mais chacun ne voit et ne modifie que ses
  propres données (filtrage par propriétaire dans `services.py`) ; un
  administrateur voit tout.
- `/api/modeles/` — lecture ouverte à tout authentifié ; création /
  modification / suppression réservées aux administrateurs (décision de
  conception : un modèle NIR entraîné est une donnée de configuration
  scientifique sensible, au même titre que `Configuration`). La création
  accepte l'upload du fichier de modèle entraîné (`fichier`, multipart) —
  voir « Import de modèle » ci-dessous pour les garanties de sécurité.
- `POST /api/analyses/export/` — génère un export (résultats et/ou spectres,
  CSV/XLSX/PDF) et renvoie l'enregistrement `Rapport` associé, avec
  `url_telechargement` ; `GET /api/rapports/<id>/telecharger/` sert ensuite
  le fichier, réservé à l'auteur de l'export ou à un administrateur.

## Tests

```bash
pytest
```

Au moins un test par endpoint critique, avec systématiquement un cas
« utilisateur non-administrateur refusé » pour les routes protégées
(`/api/utilisateurs/`, `/api/configuration/`, écritures sur `/api/modeles/`),
et des tests d'isolation des données entre utilisateurs (échantillons,
spectres, résultats).

## Variables d'environnement

Voir `.env.example`. Notamment :

- `MAX_TENTATIVES_ECHOUEES`, `DUREE_VERROUILLAGE_MINUTES` — verrouillage de compte.
- `DUREE_VALIDITE_CODE_RESET_MINUTES` — durée de validité du code de réinitialisation.
- `DJANGO_EMAIL_BACKEND` — `console` en dev (le mail est affiché dans les logs) ; à remplacer par un vrai backend SMTP en production.

## Frontend (Flutter)

Application mobile en architecture clean (`data`/`domain`/`presentation` par
feature), state management par `flutter_riverpod`, injection de dépendances
par `get_it`, appels réseau via `dio`.

### Navigation

La coquille de navigation (`core/navigation/app_router.dart`,
`coquille_navigation.dart`) repose sur `go_router` et une
`StatefulShellRoute.indexedStack` : chaque onglet a son propre `Navigator`
imbriqué (donc sa propre pile, préservée quand on change d'onglet), et la
barre de navigation du bas est déclarée une seule fois — jamais empilée par
un écran individuel. Seuls le login et le parcours mot de passe oublié sont
des routes racines, hors coquille (pas de barre du bas).

### Features

- **`authentification`** — connexion, réinitialisation de mot de passe en
  trois écrans (email → code → nouveau mot de passe).
- **`dashboard`** — écran d'accueil : statistiques, état réel de l'analyseur,
  échantillons/analyses récents (consomme `/api/dashboard/statistiques/`).
- **`analyseur`** — abstraction du module Bluetooth pilotant le
  spectromètre (`AnalyseurRepository`), avec deux implémentations
  interchangeables via configuration (`get_it`) : `AnalyseurSimuleImpl`
  (spectre NIR simulé, développement/démo sans matériel) et
  `AnalyseurBluetoothImpl` (Bluetooth Classic/SPP, connexion automatique à
  l'appareil déjà appairé). Le protocole du spectromètre n'étant pas encore
  documenté par le fabricant, ses hypothèses (trames, commandes) sont
  isolées dans un unique fichier commenté,
  `data/protocole/protocole_spectrometre.dart`.
- **`nouvelle_analyse`** — parcours en 4 étapes : Connexion (nouvelle étape
  d'entrée — état réel de la liaison Bluetooth, infos de l'appareil une fois
  connecté, sous-écran "Configuration de l'appareil" pour choisir l'appareil
  appairé à mémoriser par défaut et tester la connexion, lien "Continuer
  sans appareil" pour saisir un échantillon hors ligne), puis Échantillon,
  Analyse (carte de connexion à l'instrument en temps réel, aperçu du
  spectre en direct avec indicateurs de qualité du signal calculés à partir
  du signal réellement reçu) et Résultats. La connexion automatique reste le
  comportement par défaut ; cette étape la rend seulement visible et donne
  un recours en cas d'échec.
- **`historique`** — recherche, filtres et statistiques rapides côté serveur
  (`/api/analyses/historique/`, `/api/analyses/statistiques-rapides/`),
  liste paginée groupée par mois. Export fonctionnel : feuille de choix
  (résultats/spectres/les deux, filtres actifs ou sélection manuelle dans la
  liste, format CSV/XLSX/PDF), génération réelle du fichier côté backend
  puis téléchargement et enregistrement local (`file_picker`).
- **`modeles`** — consultation des modèles NIR disponibles ; import d'un
  modèle déjà entraîné et activation/dépréciation, réservés aux
  administrateurs (bouton visible seulement pour ce rôle, permission
  revérifiée côté backend).
- **`alertes`** — liste des alertes remontées par le backend.
- **`profil`** — écran "Mon Profil" : identité (photo, rôle), informations
  personnelles, changement de mot de passe, sessions actives (avec
  révocation), à propos/aide/mentions légales.
- **`configuration`** — préférences d'analyse (seuils de conformité/qualité)
  et notifications, lues/modifiées via `/api/configuration/` (modification
  réservée aux administrateurs).
- **`parametres`** — langue (FR/EN) et thème (clair/sombre/système), via
  `l10n/` (fichiers `.arb` + classes générées dans `l10n/generated/`) ;
  préférences persistées localement et appliquées immédiatement.
- **Mode démo** — un compte de démonstration avec de vraies données côté
  API (`core/demo/`) ; jamais de dataset factice affiché localement.

### Synchronisation hors ligne

`core/local_storage/` (base SQLite locale via `drift`) et
`core/sync/synchronisation_service.dart` : toute analyse (échantillon,
spectre) est toujours écrite en local d'abord, avec un UUID généré côté
mobile (le backend accepte cet ID tel quel, la synchronisation est donc
idempotente). Le service pousse ensuite les enregistrements en attente vers
l'API dès qu'une connexion est disponible, retente automatiquement ceux qui
ont échoué, et peut être désactivé (les données restent alors en local sans
jamais être envoyées) — voir la carte "Synchronisation cloud" de l'écran
Profil.

## Notes de conception

- **Mode démo** : ce backend ne contient aucune logique de "mode démo" (pas
  de flag `is_demo`, pas de compte ni d'endpoint de démonstration). Le mode
  démo évoqué pour la première version de l'app mobile est une
  fonctionnalité strictement frontend (données factices affichées
  localement, sans appel réseau) et n'a donc aucun impact ici.
- **Clés primaires** : `Utilisateur`, `Modele`, `Configuration` et `Alerte`
  utilisent un entier auto-incrémenté classique (jamais créés hors ligne côté
  mobile). `Echantillon`, `Spectre`, `Resultat` et `Rapport` utilisent un UUID
  (peuvent être créés hors ligne sur mobile puis synchronisés, sans risque de
  collision d'ID).
- **`rapports`** : pas de CRUD REST direct (toujours pas de `RapportViewSet`),
  seulement `GET /api/rapports/<id>/telecharger/`. Un `Rapport` est créé et
  son fichier généré par `POST /api/analyses/export/`
  (`analyses/services.py::declencher_export`, `analyses/export.py` pour la
  mise en forme CSV/XLSX/PDF). Les spectres sont toujours exportés au format
  long (une ligne par point de mesure : échantillon, longueur d'onde,
  absorbance) — un spectre comportant ~1000 points, une ligne par spectre
  avec une colonne par longueur d'onde serait inexploitable en tableur. Le
  nombre d'analyses exportables en une requête est plafonné
  (`LIMITE_EXPORT_ANALYSES`, 500) pour éviter un timeout HTTP silencieux sur
  un très gros export ; au-delà, l'API renvoie une erreur explicite plutôt
  que de laisser la requête expirer.
- **`dashboard`** et **`analyses`** : apps sans modèle propre, agrègent en
  lecture seule les données d'`echantillons`/`resultats`
  (`dashboard/services.py`, `analyses/services.py`) — tout le
  filtrage/tri/pagination se fait en base (ORM), jamais en mémoire.
- **Import de modèle et sécurité de la désérialisation** : un modèle
  scikit-learn est généralement sérialisé en pickle/joblib, dont le
  chargement peut exécuter du code arbitraire. `POST /api/modeles/` (réservé
  aux administrateurs) valide donc uniquement l'extension
  (`Modele.EXTENSIONS_AUTORISEES` : `pkl`, `pickle`, `joblib`) et la taille
  (`Modele.TAILLE_MAX_OCTETS`, 50 Mo), stocke le fichier tel quel sous un nom
  généré côté serveur (jamais le nom fourni par le client), et calcule son
  empreinte SHA-256 (`empreinte_sha256`) pour vérification d'intégrité
  ultérieure — **le fichier n'est jamais ouvert ni désérialisé par l'API**
  (`modeles/services.py` ne fait que lire ses octets bruts pour le hash). Le
  chargement effectif d'un modèle pour l'inférence relève d'un processus
  séparé et contrôlé (hors périmètre de cette API), qui doit vérifier
  l'empreinte avant toute désérialisation.
- **Pas de restauration de base de données depuis l'app mobile** : l'espace
  administrateur (`administration/`) expose l'export global des analyses et
  une purge des données antérieures à une date choisie
  (`administration/services.py::previsualiser_purge` / `purger_donnees_avant`,
  `GestionDonneesAdminScreen` côté Flutter), mais **aucune fonctionnalité de
  restauration** (réimport d'une sauvegarde, rollback de purge, etc.). Une
  restauration réécrit potentiellement toute la base à partir d'un fichier
  externe — un risque disproportionné à exposer sur un terminal mobile,
  potentiellement partagé ou volé, alors qu'un simple token JWT suffit à s'y
  authentifier. Cette opération reste un geste d'infrastructure volontairement
  réservé à un accès direct au serveur (`pg_dump`/`pg_restore`, ou l'outillage
  de sauvegarde de l'hébergeur), hors de portée de l'API REST comme de
  l'application.
