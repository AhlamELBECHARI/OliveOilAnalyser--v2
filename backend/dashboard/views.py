from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from . import services
from .serializers import StatistiquesDashboardSerializer


class StatistiquesDashboardView(APIView):
    """GET /api/dashboard/statistiques/ — agrégation en une seule requête
    pour l'écran d'accueil (analyses, échantillons, série 7 jours,
    répartition qualité, activité récente). Filtré par utilisateur : un
    administrateur voit l'agrégat de toutes les données."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses=StatistiquesDashboardSerializer)
    def get(self, request):
        donnees = services.obtenir_statistiques(utilisateur=request.user)
        serializer = StatistiquesDashboardSerializer(donnees)
        return Response(serializer.data)
