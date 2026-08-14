"""Toute la logique métier (et les requêtes ORM) pour les alertes."""

from django.utils import timezone

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


def resoudre_alerte(*, alerte, utilisateur):
    """Réservé aux administrateurs (voir AlerteViewSet.resoudre) — l'écran
    Supervision rend chaque alerte non résolue cliquable pour la résoudre."""
    alerte.est_resolue = True
    alerte.date_resolution = timezone.now()
    alerte.resolue_par = utilisateur
    alerte.save(update_fields=["est_resolue", "date_resolution", "resolue_par"])
    return alerte
