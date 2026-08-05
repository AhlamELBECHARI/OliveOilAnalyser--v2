# Olive IQ — OliveOilAnalyser

**Analyse de la qualité de l'huile d'olive par spectroscopie.**

- **Institution :** UM6P - Foundation Mascir
- **Auteur :** Ahlam EL BECHARI

## Structure du dépôt

- `backend/` — API Django REST Framework (voir ci-dessous)
- `frontend/` — application Flutter (authentification, dashboard, historique, modèles, alertes, paramètres — voir ci-dessous)
- `docs/` — diagrammes de conception et maquettes

## Documentation visuelle

- Diagrammes de conception : `docs/diagrams/`
- Maquettes de l'application : `docs/maquette/`

## Backend

## Stack

- Django + Django REST Framework (DRF)
- PostgreSQL (via `psycopg` v3)
- `djangorestframework-simplejwt` (JWT access + refresh, avec `token_blacklist` activé)
- Mots de passe hashés avec bcrypt (`BCryptSHA256PasswordHasher`)
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
| `comptes` | `Utilisateur`, `Configuration` | `/api/auth/*`, `/api/utilisateurs/`, `/api/configuration/` |
| `echantillons` | `Echantillon` | `/api/echantillons/` |
| `spectres` | `Spectre` | `/api/spectres/` |
| `modeles` | `Modele` | `/api/modeles/` |
| `resultats` | `Resultat` | `/api/resultats/` |
| `rapports` | `Rapport` | modèle + admin Django uniquement (pas d'endpoint ce jalon) |
| `alertes` | `Alerte` | `/api/alertes/` |
| `dashboard` | *(aucun — agrège en lecture seule)* | `/api/dashboard/statistiques/` |

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
- `POST /api/auth/reset-password/` puis `POST /api/auth/reset-password/confirmer/`
  — réinitialisation en deux temps. Seul un hash SHA-256 du token est stocké
  côté serveur (jamais le token en clair) ; en dev, l'email est affiché dans
  les logs du conteneur `web` (backend console). À la confirmation, tous les
  refresh tokens existants de l'utilisateur sont blacklistés
  (`rest_framework_simplejwt.token_blacklist`).
- `GET /api/utilisateurs/` et `GET`/`PUT /api/configuration/` — réservés aux
  administrateurs (`core.permissions.IsAdministrateur`).
- `/api/echantillons/`, `/api/spectres/`, `/api/resultats/` — CRUD ouvert à
  tout utilisateur authentifié, mais chacun ne voit et ne modifie que ses
  propres données (filtrage par propriétaire dans `services.py`) ; un
  administrateur voit tout.
- `/api/modeles/` — lecture ouverte à tout authentifié ; création /
  modification / suppression réservées aux administrateurs (décision de
  conception : un modèle NIR entraîné est une donnée de configuration
  scientifique sensible, au même titre que `Configuration`).

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
- `DUREE_VALIDITE_TOKEN_RESET_MINUTES` — durée de validité d'un token de reset.
- `DJANGO_EMAIL_BACKEND` — `console` en dev (le mail est affiché dans les logs) ; à remplacer par un vrai backend SMTP en production.

## Frontend (Flutter)

Application mobile en architecture clean (`data`/`domain`/`presentation` par
feature), state management par `provider`, appels réseau via `dio`.

- **`authentification`** — connexion, réinitialisation de mot de passe en
  trois écrans (email → code → nouveau mot de passe).
- **`dashboard`** — écran d'accueil : statistiques, état de l'analyseur,
  échantillons/analyses récents (consomme `/api/dashboard/statistiques/`).
- **`historique`** — liste et détail des résultats d'analyse passés.
- **`modeles`** — consultation des modèles NIR disponibles.
- **`alertes`** — liste des alertes remontées par le backend.
- **`parametres`** — choix de la langue (FR/EN), via `l10n/` (fichiers
  `.arb` + classes générées dans `l10n/generated/`).
- **Mode démo** — données factices affichées localement sans appel réseau
  (`core/demo/`), pour démonstration hors backend.

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
- **`rapports`** : modèle et admin Django prêts, mais sans endpoint REST —
  hors périmètre des endpoints minimum de ce jalon. À exposer dans un
  prochain jalon si besoin.
- **`dashboard`** : app sans modèle propre, agrège en lecture seule les
  données d'`echantillons`/`resultats` (`dashboard/services.py`) pour
  alimenter l'écran d'accueil du mobile (statistiques, état du laboratoire,
  activité récente).
