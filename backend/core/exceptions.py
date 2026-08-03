"""
Handler d'exceptions DRF centralisé.

Complète le comportement par défaut de DRF (qui gère déjà proprement 400,
401, 403, 404) pour transformer les erreurs base de données qui, sinon,
remonteraient en 500 :
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


def gestionnaire_exceptions(exc, context):
    if isinstance(exc, ProtectedError):
        return Response(
            {
                "detail": (
                    "Impossible de supprimer cette ressource : elle est "
                    "référencée par d'autres données."
                )
            },
            status=status.HTTP_409_CONFLICT,
        )

    if isinstance(exc, IntegrityError):
        logger.warning("IntegrityError non gérée en amont: %s", exc)
        return Response(
            {"detail": "Cette opération viole une contrainte d'intégrité des données."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if isinstance(exc, Http404):
        exc = drf_exceptions.NotFound()

    if isinstance(exc, DjangoPermissionDenied):
        exc = drf_exceptions.PermissionDenied()

    return drf_exception_handler(exc, context)
