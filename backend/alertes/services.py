"""Toute la logique métier (et les requêtes ORM) pour les alertes."""

from .models import Alerte


def lister_alertes(*, utilisateur, est_resolue=None):
    """Lecture seule pour ce jalon. Un utilisateur standard ne voit que les
    alertes liées à ses propres échantillons ; un administrateur voit tout,
    y compris les alertes système sans échantillon associé (echantillon=None).
    `est_resolue` permet de filtrer (utilisé par le frontend pour la pastille
    de notifications, sans devoir charger toutes les alertes)."""
    queryset = Alerte.objects.select_related("echantillon", "resolue_par").all()
    if utilisateur.role != utilisateur.Role.ADMINISTRATEUR:
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    if est_resolue is not None:
        queryset = queryset.filter(est_resolue=est_resolue)
    return queryset
