from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from core.permissions import IsAdministrateur

from . import services
from .serializers import HistoriqueUtilisationModeleSerializer, ModeleSerializer


class ModeleViewSet(viewsets.ModelViewSet):
    """CRUD sur /api/modeles/. Lecture et import (create) ouverts à tout
    utilisateur authentifié — un utilisateur standard peut consulter et
    importer un modèle déjà entraîné. Modification (déprécier/réactiver,
    définir le modèle de référence) et suppression restent réservées aux
    administrateurs (voir l'espace admin), ces actions affectant le modèle
    utilisé par TOUS les utilisateurs, pas seulement son auteur."""

    serializer_class = ModeleSerializer

    def get_permissions(self):
        # historique_utilisation reste réservé aux administrateurs (voir
        # l'espace admin — "Consulter l'historique d'utilisation").
        if self.action in ("list", "retrieve", "create"):
            return [IsAuthenticated()]
        return [IsAdministrateur()]

    def get_queryset(self):
        return services.lister_modeles()

    def perform_create(self, serializer):
        serializer.instance = services.creer_modele(**serializer.validated_data)

    def perform_update(self, serializer):
        serializer.instance = services.modifier_modele(
            modele=serializer.instance, acteur=self.request.user, **serializer.validated_data
        )

    def perform_destroy(self, instance):
        services.supprimer_modele(modele=instance, acteur=self.request.user)

    @action(detail=True, methods=["get"], url_path="historique-utilisation")
    def historique_utilisation(self, request, pk=None):
        """GET /api/modeles/<id>/historique-utilisation/ — nombre de
        résultats produits par ce modèle et date de sa dernière utilisation."""
        modele = self.get_object()
        donnees = services.historique_utilisation(modele=modele)
        return Response(HistoriqueUtilisationModeleSerializer(donnees).data)
