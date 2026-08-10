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
    """POST /api/analyses/export/ — génère réellement le fichier d'export
    (résultats et/ou spectres, CSV/XLSX/PDF) et l'associe à l'enregistrement
    Rapport créé pour tracer qui a exporté quoi et quand (voir
    analyses.services.declencher_export). La réponse inclut
    `url_telechargement`, à appeler ensuite pour récupérer le fichier."""

    permission_classes = [IsAuthenticated]

    @extend_schema(request=ExportDemandeSerializer, responses=RapportSerializer)
    def post(self, request):
        demande = ExportDemandeSerializer(data=request.data)
        demande.is_valid(raise_exception=True)
        donnees = dict(demande.validated_data)
        format_rapport = donnees.pop("format")
        rapport = services.declencher_export(
            utilisateur=request.user, format_rapport=format_rapport, **donnees
        )
        serializer = RapportSerializer(rapport, context={"request": request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)
