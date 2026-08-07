"""
Handler d'exceptions DRF centralisé + codes d'erreur stables.

Toute réponse d'erreur JSON contient désormais deux champs :
- "detail" : message lisible, en français, destiné aux logs/au débogage —
  jamais garanti traduit, le frontend ne doit jamais l'afficher tel quel.
- "code"   : identifiant stable et non traduit (voir CodesErreur), que le
  frontend mappe vers son propre texte localisé (fichiers ARB Flutter).

Complète aussi le comportement par défaut de DRF (qui gère déjà proprement
400, 401, 403, 404) pour transformer les erreurs base de données qui,
sinon, remonteraient en 500 :
- ProtectedError (suppression bloquée par un on_delete=PROTECT) -> 409
- IntegrityError de clé dupliquée (23505) -> 409 : cas du retry réseau de
  la synchronisation hors ligne (frontend/Drift), qui renvoie parfois deux
  fois la même requête avec le même UUID généré côté mobile ; le service
  de synchronisation interprète ce 409 comme "déjà synchronisé".
- IntegrityError non anticipée (autre contrainte violée en base) -> 400
"""

import logging

from django.core.exceptions import PermissionDenied as DjangoPermissionDenied
from django.db import IntegrityError
from django.db.models import ProtectedError
from django.http import Http404
from rest_framework import exceptions as drf_exceptions
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_exception_handler

logger = logging.getLogger(__name__)


class CodesErreur:
    """Codes d'erreur stables et non traduits. Centralisés ici pour éviter
    que chaque app ne réinvente ses propres chaînes magiques."""

    IDENTIFIANTS_INVALIDES = "identifiants_invalides"
    COMPTE_VERROUILLE = "compte_verrouille"
    COMPTE_DESACTIVE = "compte_desactive"
    CODE_RESET_INVALIDE = "code_reset_invalide"
    MOT_DE_PASSE_ACTUEL_INVALIDE = "mot_de_passe_actuel_invalide"
    TROP_DE_DEMANDES = "trop_de_demandes"
    VALIDATION = "validation"
    RESSOURCE_PROTEGEE = "ressource_protegee"
    RESSOURCE_DEJA_EXISTANTE = "ressource_deja_existante"
    INTEGRITE = "integrite"
    NON_TROUVE = "non_trouve"
    PERMISSION_REFUSEE = "permission_refusee"
    NON_AUTHENTIFIE = "non_authentifie"
    ERREUR_SERVEUR = "erreur_serveur"


class ErreurMetier(drf_exceptions.APIException):
    """Exception de base portant un code d'erreur stable en plus du message
    lisible. Toute erreur métier connue (comptes.services, etc.) doit lever
    une sous-classe de celle-ci plutôt qu'une exception DRF générique, pour
    que le frontend puisse distinguer les cas sans parser le texte du
    message."""

    code_erreur = CodesErreur.ERREUR_SERVEUR


class IdentifiantsInvalidesError(ErreurMetier):
    status_code = status.HTTP_401_UNAUTHORIZED
    default_detail = "Identifiants invalides."
    code_erreur = CodesErreur.IDENTIFIANTS_INVALIDES


class CompteVerrouilleError(ErreurMetier):
    status_code = status.HTTP_401_UNAUTHORIZED
    default_detail = (
        "Compte temporairement verrouillé suite à plusieurs échecs de "
        "connexion. Réessayez plus tard."
    )
    code_erreur = CodesErreur.COMPTE_VERROUILLE


class CompteDesactiveError(ErreurMetier):
    status_code = status.HTTP_401_UNAUTHORIZED
    default_detail = "Ce compte est désactivé."
    code_erreur = CodesErreur.COMPTE_DESACTIVE


class CodeResetInvalideError(ErreurMetier):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = "Code invalide ou expiré."
    code_erreur = CodesErreur.CODE_RESET_INVALIDE


class MotDePasseActuelInvalideError(ErreurMetier):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = "Le mot de passe actuel est incorrect."
    code_erreur = CodesErreur.MOT_DE_PASSE_ACTUEL_INVALIDE


class TropDeDemandesError(ErreurMetier):
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    default_detail = "Trop de demandes de code. Réessayez plus tard."
    code_erreur = CodesErreur.TROP_DE_DEMANDES


def _code_par_defaut(exc):
    """Code de repli pour les exceptions DRF génériques (pas des
    ErreurMetier) : garantit qu'aucune réponse d'erreur ne part sans code."""
    if isinstance(exc, drf_exceptions.Throttled):
        return CodesErreur.TROP_DE_DEMANDES
    if isinstance(exc, drf_exceptions.NotFound):
        return CodesErreur.NON_TROUVE
    if isinstance(exc, drf_exceptions.PermissionDenied):
        return CodesErreur.PERMISSION_REFUSEE
    if isinstance(exc, drf_exceptions.NotAuthenticated):
        return CodesErreur.NON_AUTHENTIFIE
    if isinstance(exc, drf_exceptions.AuthenticationFailed):
        return CodesErreur.IDENTIFIANTS_INVALIDES
    if isinstance(exc, drf_exceptions.ValidationError):
        return CodesErreur.VALIDATION
    return CodesErreur.ERREUR_SERVEUR


def _est_violation_cle_dupliquee(exc):
    """Spécifiquement une clé PRIMAIRE dupliquée (retry réseau de la
    synchronisation hors ligne renvoyant deux fois le même UUID mobile) —
    pas n'importe quelle contrainte unique. Une violation d'unicité métier
    (ex. numéro d'échantillon déjà utilisé par le même utilisateur) doit
    rester un 400 de validation classique, pas un 409 "déjà synchronisé".
    23505 est le SQLSTATE Postgres standard pour "unique_violation" ;
    Django expose l'exception native du driver dans `__cause__`, dont le
    nom de contrainte suit la convention `<table>_pkey` pour une PK."""
    cause = exc.__cause__
    if getattr(cause, "sqlstate", None) != "23505":
        return False
    diag = getattr(cause, "diag", None)
    constraint = getattr(diag, "constraint_name", None) if diag else None
    return bool(constraint) and constraint.endswith("_pkey")


def gestionnaire_exceptions(exc, context):
    if isinstance(exc, ProtectedError):
        return Response(
            {
                "code": CodesErreur.RESSOURCE_PROTEGEE,
                "detail": (
                    "Impossible de supprimer cette ressource : elle est "
                    "référencée par d'autres données."
                ),
            },
            status=status.HTTP_409_CONFLICT,
        )

    if isinstance(exc, IntegrityError):
        if _est_violation_cle_dupliquee(exc):
            return Response(
                {
                    "code": CodesErreur.RESSOURCE_DEJA_EXISTANTE,
                    "detail": "Une ressource avec cet identifiant existe déjà.",
                },
                status=status.HTTP_409_CONFLICT,
            )
        logger.warning("IntegrityError non gérée en amont: %s", exc)
        return Response(
            {
                "code": CodesErreur.INTEGRITE,
                "detail": "Cette opération viole une contrainte d'intégrité des données.",
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    if isinstance(exc, Http404):
        exc = drf_exceptions.NotFound()

    if isinstance(exc, DjangoPermissionDenied):
        exc = drf_exceptions.PermissionDenied()

    reponse = drf_exception_handler(exc, context)
    if reponse is None:
        return None

    code = getattr(exc, "code_erreur", None) or _code_par_defaut(exc)
    if isinstance(reponse.data, dict) and "code" not in reponse.data:
        reponse.data["code"] = code

    return reponse
