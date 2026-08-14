"""
Configuration Django pour le backend Olive IQ.
"""

from datetime import timedelta
from pathlib import Path

from dotenv import load_dotenv
import os

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")


def env(name, default=None):
    return os.environ.get(name, default)


def env_bool(name, default=False):
    valeur = os.environ.get(name)
    if valeur is None:
        return default
    return valeur.strip().lower() in ("1", "true", "yes", "on")


def env_list(name, default=""):
    valeur = os.environ.get(name, default)
    return [item.strip() for item in valeur.split(",") if item.strip()]


# --- Sécurité de base --------------------------------------------------

SECRET_KEY = env("DJANGO_SECRET_KEY", "insecure-dev-key-change-me")
DEBUG = env_bool("DJANGO_DEBUG", True)
ALLOWED_HOSTS = env_list("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1")

# CORS : uniquement pour le développement (le mobile natif — Android/iOS/
# desktop — n'est jamais soumis à CORS, seul le build web Flutter l'est).
# Tout autoriser tant que DEBUG est actif ; en production, remplacer par une
# CORS_ALLOWED_ORIGINS explicite.
CORS_ALLOW_ALL_ORIGINS = DEBUG

# --- Applications --------------------------------------------------------

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "rest_framework_simplejwt",
    "rest_framework_simplejwt.token_blacklist",
    "drf_spectacular",
    "corsheaders",
    "comptes",
    "echantillons",
    "spectres",
    "modeles",
    "resultats",
    "rapports",
    "alertes",
    "dashboard",
    "analyses",
    "administration",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# --- Base de données -----------------------------------------------------

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": env("POSTGRES_DB", "olive_iq"),
        "USER": env("POSTGRES_USER", "olive_iq"),
        "PASSWORD": env("POSTGRES_PASSWORD", "olive_iq"),
        "HOST": env("POSTGRES_HOST", "localhost"),
        "PORT": env("POSTGRES_PORT", "5432"),
    }
}

# --- Authentification ------------------------------------------------------

AUTH_USER_MODEL = "comptes.Utilisateur"

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# bcrypt en premier : tous les nouveaux mots de passe sont hashés avec
# BCryptSHA256PasswordHasher. Les autres hashers restent déclarés pour que
# Django puisse toujours vérifier d'anciens mots de passe hashés autrement.
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher",
    "django.contrib.auth.hashers.Argon2PasswordHasher",
    "django.contrib.auth.hashers.ScryptPasswordHasher",
]

# --- Règles métier de sécurité du compte (utilisées par comptes.services) --

MAX_TENTATIVES_ECHOUEES = int(env("MAX_TENTATIVES_ECHOUEES", "5"))
DUREE_VERROUILLAGE_MINUTES = int(env("DUREE_VERROUILLAGE_MINUTES", "15"))

# Réinitialisation de mot de passe par code à 6 chiffres.
DUREE_VALIDITE_CODE_RESET_MINUTES = int(env("DUREE_VALIDITE_CODE_RESET_MINUTES", "15"))
MAX_TENTATIVES_CODE_RESET = int(env("MAX_TENTATIVES_CODE_RESET", "5"))
MAX_DEMANDES_CODE_RESET_PAR_FENETRE = int(env("MAX_DEMANDES_CODE_RESET_PAR_FENETRE", "5"))
FENETRE_DEMANDES_CODE_RESET_MINUTES = int(env("FENETRE_DEMANDES_CODE_RESET_MINUTES", "60"))

# --- Internationalisation -----------------------------------------------

LANGUAGE_CODE = "fr-fr"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

# --- Fichiers statiques et médias ------------------------------------------

STATIC_URL = "static/"

# Photos de profil (comptes.Utilisateur.photo_profil) et autres fichiers
# téléversés par les utilisateurs. Servis par Django uniquement en DEBUG
# (voir config/urls.py) : en production, un serveur web/CDN dédié doit
# prendre le relais de MEDIA_URL.
MEDIA_URL = "media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# --- Emails (reset de mot de passe) --------------------------------------

EMAIL_BACKEND = env("DJANGO_EMAIL_BACKEND", "django.core.mail.backends.console.EmailBackend")
DEFAULT_FROM_EMAIL = env("DEFAULT_FROM_EMAIL", "no-reply@olive-iq.local")

# --- Django REST Framework ------------------------------------------------

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "EXCEPTION_HANDLER": "core.exceptions.gestionnaire_exceptions",
    "DEFAULT_PAGINATION_CLASS": "core.pagination.PaginationStandard",
    "PAGE_SIZE": 20,
    "TEST_REQUEST_DEFAULT_FORMAT": "json",
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=int(env("JWT_ACCESS_LIFETIME_MIN", "30"))),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=int(env("JWT_REFRESH_LIFETIME_DAYS", "7"))),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
    # date_derniere_connexion est géré nous-mêmes dans comptes.services.login
    "UPDATE_LAST_LOGIN": False,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}

# --- drf-spectacular (OpenAPI / Swagger) ----------------------------------

SPECTACULAR_SETTINGS = {
    "TITLE": "Olive IQ API",
    "DESCRIPTION": (
        "API backend pour Olive IQ — analyseur de qualité d'huile d'olive "
        "par spectroscopie NIR."
    ),
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
}
