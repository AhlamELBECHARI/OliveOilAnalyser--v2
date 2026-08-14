from drf_spectacular.utils import extend_schema
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAdministrateur
from core.serializers import ErreurSerializer

from . import services
from .serializers import (
    JournalAuditSerializer,
    PurgeApercuSerializer,
    PurgeDemandeSerializer,
    PurgeResultatSerializer,
    StatistiquesOccupationSerializer,
    SupervisionSerializer,
)


class SupervisionView(APIView):
    """GET /api/admin/supervision/ — écran d'accueil admin, une seule
    requête pour tout l'écran (voir administration.services.obtenir_supervision)."""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses={200: SupervisionSerializer, 403: ErreurSerializer})
    def get(self, request):
        return Response(SupervisionSerializer(services.obtenir_supervision()).data)


class JournalAuditListView(generics.ListAPIView):
    """GET /api/admin/journal-audit/?action=&acteur_id= — historique des
    actions sensibles (voir administration.models.JournalAudit)."""

    serializer_class = JournalAuditSerializer
    permission_classes = [IsAdministrateur]

    def get_queryset(self):
        parametres = self.request.query_params
        return services.lister_journal_audit(
            action=parametres.get("action"),
            acteur_id=parametres.get("acteur_id"),
        )


class StatistiquesOccupationView(APIView):
    """GET /api/admin/donnees/statistiques/ — écran Gestion des données."""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses={200: StatistiquesOccupationSerializer, 403: ErreurSerializer})
    def get(self, request):
        return Response(StatistiquesOccupationSerializer(services.statistiques_occupation()).data)


class PurgeApercuView(APIView):
    """POST /api/admin/donnees/purge/apercu/ — récapitulatif de ce qui
    SERAIT supprimé, sans rien supprimer (garde-fou "confirmation explicite
    avec récapitulatif" avant la purge réelle)."""

    permission_classes = [IsAdministrateur]

    @extend_schema(
        request=PurgeDemandeSerializer,
        responses={200: PurgeApercuSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def post(self, request):
        serializer = PurgeDemandeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        apercu = services.previsualiser_purge(date_limite=serializer.validated_data["date_limite"])
        return Response(PurgeApercuSerializer(apercu).data)


class PurgeExecuterView(APIView):
    """POST /api/admin/donnees/purge/ — supprime réellement les échantillons
    (et leurs spectres/résultats) antérieurs à `date_limite`, et journalise
    l'action. Irréversible : le client DOIT être passé par
    PurgeApercuView avant d'appeler cette route."""

    permission_classes = [IsAdministrateur]

    @extend_schema(
        request=PurgeDemandeSerializer,
        responses={200: PurgeResultatSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def post(self, request):
        serializer = PurgeDemandeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        resultat = services.purger_donnees_avant(
            date_limite=serializer.validated_data["date_limite"], utilisateur=request.user
        )
        return Response(PurgeResultatSerializer(resultat).data)
