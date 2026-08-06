from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from . import services
from .serializers import (
    ExportDemandeSerializer,
    RapportSerializer,
    ResultatHistoriqueSerializer,
    StatistiquesRapidesSerializer,
)


class HistoriqueAnalysesView(generics.ListAPIView):
    """GET /api/analyses/historique/ — recherche plein texte (?recherche=)
    et filtres (?qualite=, ?variete=, ?region=, ?date_debut=, ?date_fin=)
    + tri (?tri=), tout appliqué en base via
    analyses.services.rechercher_historique. Pagination standard
    (core.pagination.PaginationStandard, appliquée par défaut)."""

    serializer_class = ResultatHistoriqueSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        parametres = self.request.query_params
        return services.rechercher_historique(
            utilisateur=self.request.user,
            recherche=parametres.get("recherche"),
            qualite=parametres.get("qualite"),
            variete=parametres.get("variete"),
            region=parametres.get("region"),
            date_debut=parametres.get("date_debut"),
            date_fin=parametres.get("date_fin"),
            tri=parametres.get("tri"),
        )


class StatistiquesRapidesView(APIView):
    """GET /api/analyses/statistiques-rapides/ — carte "Aperçu" (total,
    répartition qualité, ce mois) + les 4 indicateurs à mini-série de bas
    de page (tendance acidité, meilleure/plus forte acidité, fréquence
    d'analyses), tous calculés par agrégation ORM."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses=StatistiquesRapidesSerializer)
    def get(self, request):
        donnees = services.obtenir_statistiques_rapides(utilisateur=request.user)
        return Response(StatistiquesRapidesSerializer(donnees).data)


class ExportAnalysesView(APIView):
    """POST /api/analyses/export/ — déclenche la génération d'un rapport en
    créant l'enregistrement Rapport correspondant. La génération effective
    du fichier n'est pas dans le périmètre de ce jalon (voir
    analyses.services.declencher_export)."""

    permission_classes = [IsAuthenticated]

    @extend_schema(request=ExportDemandeSerializer, responses=RapportSerializer)
    def post(self, request):
        demande = ExportDemandeSerializer(data=request.data)
        demande.is_valid(raise_exception=True)
        rapport = services.declencher_export(
            utilisateur=request.user, format_rapport=demande.validated_data["format"]
        )
        return Response(RapportSerializer(rapport).data, status=status.HTTP_201_CREATED)
