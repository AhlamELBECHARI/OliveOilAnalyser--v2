"""Toute la logique métier (et les requêtes ORM) pour les résultats."""

from rest_framework.exceptions import PermissionDenied

from .models import Resultat


def lister_resultats(*, utilisateur):
    """Un utilisateur standard ne voit que les résultats de ses propres
    échantillons ; un administrateur voit tout."""
    queryset = Resultat.objects.select_related(
        "echantillon", "echantillon__utilisateur", "modele_utilise", "valide_par"
    ).all()
    if utilisateur.role != utilisateur.Role.ADMINISTRATEUR:
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    return queryset


def _verifier_acces_echantillon(*, utilisateur, echantillon):
    if (
        utilisateur.role != utilisateur.Role.ADMINISTRATEUR
        and echantillon.utilisateur_id != utilisateur.id
    ):
        raise PermissionDenied("Vous n'avez pas accès à cet échantillon.")


def creer_resultat(*, utilisateur, echantillon, **donnees):
    _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=echantillon)
    return Resultat.objects.create(echantillon=echantillon, **donnees)


def modifier_resultat(*, utilisateur, resultat, **donnees):
    nouvel_echantillon = donnees.get("echantillon")
    if nouvel_echantillon is not None:
        _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=nouvel_echantillon)
    for champ, valeur in donnees.items():
        setattr(resultat, champ, valeur)
    resultat.save()
    return resultat


def supprimer_resultat(*, resultat):
    resultat.delete()
