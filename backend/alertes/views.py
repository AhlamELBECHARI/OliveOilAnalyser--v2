from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from core.permissions import IsAdministrateur

from . import services
from .serializers import AlerteSerializer


class AlerteViewSet(viewsets.ReadOnlyModelViewSet):
    """Lecture seule sur /api/alertes/ — les alertes sont générées par le
    système, jamais créées par les utilisateurs. Seule la résolution
    (réservée aux administrateurs, voir `resoudre`) est une écriture."""

    serializer_class = AlerteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        est_resolue_brut = self.request.query_params.get("est_resolue")
        est_resolue = None
        if est_resolue_brut is not None:
            est_resolue = est_resolue_brut.strip().lower() in ("1", "true")
        return services.lister_alertes(utilisateur=self.request.user, est_resolue=est_resolue)

    @action(detail=True, methods=["post"], permission_classes=[IsAdministrateur])
    def resoudre(self, request, pk=None):
        """POST /api/alertes/<id>/resoudre/ — utilisé par l'écran
        Supervision ("cliquable pour résoudre")."""
        alerte = self.get_object()
        alerte = services.resoudre_alerte(alerte=alerte, utilisateur=request.user)
        return Response(AlerteSerializer(alerte).data)
