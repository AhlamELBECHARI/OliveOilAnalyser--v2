from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from core.permissions import EstProprietaireOuAdministrateur

from . import services
from .serializers import EchantillonSerializer


class EchantillonViewSet(viewsets.ModelViewSet):
    """CRUD complet sur /api/echantillons/. Un utilisateur standard ne voit
    et ne modifie que ses propres échantillons ; un administrateur voit tout."""

    serializer_class = EchantillonSerializer
    permission_classes = [IsAuthenticated, EstProprietaireOuAdministrateur]

    def get_queryset(self):
        return services.lister_echantillons(utilisateur=self.request.user)

    def perform_create(self, serializer):
        serializer.instance = services.creer_echantillon(
            utilisateur=self.request.user, **serializer.validated_data
        )

    def perform_update(self, serializer):
        serializer.instance = services.modifier_echantillon(
            echantillon=serializer.instance, **serializer.validated_data
        )

    def perform_destroy(self, instance):
        services.supprimer_echantillon(echantillon=instance)
