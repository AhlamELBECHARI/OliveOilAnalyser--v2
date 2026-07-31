"""Toute la logique métier (et les requêtes ORM) pour les spectres."""

from rest_framework.exceptions import PermissionDenied

from .models import Spectre


def lister_spectres(*, utilisateur):
    """Un utilisateur standard ne voit que les spectres de ses propres
    échantillons ; un administrateur voit tout."""
    queryset = Spectre.objects.select_related("echantillon", "echantillon__utilisateur").all()
    if utilisateur.role != utilisateur.Role.ADMINISTRATEUR:
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    return queryset


def _verifier_acces_echantillon(*, utilisateur, echantillon):
    if (
        utilisateur.role != utilisateur.Role.ADMINISTRATEUR
        and echantillon.utilisateur_id != utilisateur.id
    ):
        raise PermissionDenied("Vous n'avez pas accès à cet échantillon.")


def creer_spectre(*, utilisateur, echantillon, **donnees):
    _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=echantillon)
    return Spectre.objects.create(echantillon=echantillon, **donnees)


def modifier_spectre(*, utilisateur, spectre, **donnees):
    nouvel_echantillon = donnees.get("echantillon")
    if nouvel_echantillon is not None:
        _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=nouvel_echantillon)
    for champ, valeur in donnees.items():
        setattr(spectre, champ, valeur)
    spectre.save()
    return spectre


def supprimer_spectre(*, spectre):
    spectre.delete()
