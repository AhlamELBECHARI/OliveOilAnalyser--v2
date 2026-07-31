from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from . import services
from .serializers import ResultatSerializer


class ResultatViewSet(viewsets.ModelViewSet):
    """CRUD complet sur /api/resultats/. Un utilisateur standard ne voit et
    ne modifie que les résultats de ses propres échantillons."""

    serializer_class = ResultatSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return services.lister_resultats(utilisateur=self.request.user)

    def perform_create(self, serializer):
        serializer.instance = services.creer_resultat(
            utilisateur=self.request.user, **serializer.validated_data
        )

    def perform_update(self, serializer):
        serializer.instance = services.modifier_resultat(
            utilisateur=self.request.user,
            resultat=serializer.instance,
            **serializer.validated_data,
        )

    def perform_destroy(self, instance):
        services.supprimer_resultat(resultat=instance)
