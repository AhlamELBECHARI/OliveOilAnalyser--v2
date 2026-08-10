import os

from django.core.exceptions import PermissionDenied as DjangoPermissionDenied
from django.core.files.storage import default_storage
from django.http import FileResponse, Http404
from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView

from core.permissions import ROLE_ADMINISTRATEUR

from .models import Rapport


class TelechargerRapportView(APIView):
    """GET /api/rapports/<id>/telecharger/ — sert le fichier généré pour ce
    rapport (voir analyses.services.declencher_export pour la génération).
    Réservé à son auteur (genere_par) ou à un administrateur : un rapport
    peut porter sur les analyses d'autres utilisateurs si son auteur est
    administrateur, mais ne doit jamais fuiter vers un tiers non autorisé."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: bytes})
    def get(self, request, pk):
        try:
            rapport = Rapport.objects.get(pk=pk)
        except Rapport.DoesNotExist as exc:
            raise Http404 from exc

        utilisateur = request.user
        est_auteur = rapport.genere_par_id == utilisateur.id
        est_administrateur = getattr(utilisateur, "role", None) == ROLE_ADMINISTRATEUR
        if not (est_auteur or est_administrateur):
            raise DjangoPermissionDenied

        if not rapport.chemin_fichier or not default_storage.exists(rapport.chemin_fichier):
            raise Http404

        return FileResponse(
            default_storage.open(rapport.chemin_fichier, "rb"),
            as_attachment=True,
            filename=os.path.basename(rapport.chemin_fichier),
        )
