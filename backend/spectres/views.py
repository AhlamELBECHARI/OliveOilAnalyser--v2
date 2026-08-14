from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from . import services
from .serializers import SpectreSerializer


class SpectreViewSet(viewsets.ModelViewSet):
    """CRUD complet sur /api/spectres/. Un utilisateur standard ne voit et ne
    modifie que les spectres de ses propres échantillons."""

    serializer_class = SpectreSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = services.lister_spectres(utilisateur=self.request.user)
        echantillon_id = self.request.query_params.get("echantillon")
        if echantillon_id:
            queryset = queryset.filter(echantillon_id=echantillon_id)
        return queryset

    def perform_create(self, serializer):
        serializer.instance = services.creer_spectre(
            utilisateur=self.request.user, **serializer.validated_data
        )

    def perform_update(self, serializer):
        serializer.instance = services.modifier_spectre(
            utilisateur=self.request.user,
            spectre=serializer.instance,
            **serializer.validated_data,
        )

    def perform_destroy(self, instance):
        services.supprimer_spectre(spectre=instance)
