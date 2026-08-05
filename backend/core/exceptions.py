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
- IntegrityError non anticipée (contrainte violée en base) -> 400
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
    TROP_DE_DEMANDES = "trop_de_demandes"
    VALIDATION = "validation"
    RESSOURCE_PROTEGEE = "ressource_protegee"
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
