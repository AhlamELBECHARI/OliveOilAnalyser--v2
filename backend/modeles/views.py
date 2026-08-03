from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from core.permissions import IsAdministrateur

from . import services
from .serializers import ModeleSerializer


class ModeleViewSet(viewsets.ModelViewSet):
    """CRUD sur /api/modeles/. Lecture ouverte à tout utilisateur authentifié ;
    création/modification/suppression réservées aux administrateurs, ces
    modèles étant des données de configuration scientifique sensibles (au
    même titre que Configuration)."""

    serializer_class = ModeleSerializer

    def get_permissions(self):
        if self.action in ("list", "retrieve"):
            return [IsAuthenticated()]
        return [IsAdministrateur()]

    def get_queryset(self):
        return services.lister_modeles()

    def perform_create(self, serializer):
        serializer.instance = services.creer_modele(**serializer.validated_data)

    def perform_update(self, serializer):
        serializer.instance = services.modifier_modele(
            modele=serializer.instance, **serializer.validated_data
        )

    def perform_destroy(self, instance):
        services.supprimer_modele(modele=instance)
