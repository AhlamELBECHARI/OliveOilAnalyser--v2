from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from . import services
from .serializers import AlerteSerializer


class AlerteViewSet(viewsets.ReadOnlyModelViewSet):
    """Lecture seule sur /api/alertes/ — écriture hors périmètre de ce jalon
    (les alertes sont générées par le système, pas par les utilisateurs)."""

    serializer_class = AlerteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        est_resolue_brut = self.request.query_params.get("est_resolue")
        est_resolue = None
        if est_resolue_brut is not None:
            est_resolue = est_resolue_brut.strip().lower() in ("1", "true")
        return services.lister_alertes(utilisateur=self.request.user, est_resolue=est_resolue)
