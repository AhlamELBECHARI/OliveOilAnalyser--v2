"""
Classes de permission DRF réutilisables par toutes les apps.

Centralisées ici pour ne jamais dupliquer la logique de rôle dans les vues.
"""

from rest_framework.permissions import BasePermission

ROLE_ADMINISTRATEUR = "administrateur"


class IsAdministrateur(BasePermission):
    """Autorise uniquement les utilisateurs authentifiés avec role=administrateur."""

    message = "Cette action est réservée aux administrateurs."

    def has_permission(self, request, view):
        utilisateur = request.user
        return bool(
            utilisateur
            and utilisateur.is_authenticated
            and getattr(utilisateur, "role", None) == ROLE_ADMINISTRATEUR
        )


class EstProprietaireOuAdministrateur(BasePermission):
    """
    Permission au niveau objet : autorise le propriétaire de la ressource
    (obj.utilisateur == request.user) ou un administrateur.

    Utilisée en défense en profondeur en complément du filtrage déjà
    appliqué par la couche services (get_queryset).
    """

    message = "Vous n'avez pas accès à cette ressource."

    def has_object_permission(self, request, view, obj):
        utilisateur = request.user
        if not (utilisateur and utilisateur.is_authenticated):
            return False
        if getattr(utilisateur, "role", None) == ROLE_ADMINISTRATEUR:
            return True
        proprietaire = getattr(obj, "utilisateur", None)
        return proprietaire is not None and proprietaire == utilisateur
