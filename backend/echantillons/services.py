"""Toute la logique métier (et les requêtes ORM) pour les échantillons."""

from .models import Echantillon


def lister_echantillons(*, utilisateur):
    """Un utilisateur standard ne voit que ses propres échantillons ;
    un administrateur voit tout."""
    queryset = Echantillon.objects.select_related("utilisateur").all()
    if utilisateur.role != utilisateur.Role.ADMINISTRATEUR:
        queryset = queryset.filter(utilisateur=utilisateur)
    return queryset


def creer_echantillon(*, utilisateur, **donnees):
    return Echantillon.objects.create(utilisateur=utilisateur, **donnees)


def modifier_echantillon(*, echantillon, **donnees):
    for champ, valeur in donnees.items():
        setattr(echantillon, champ, valeur)
    echantillon.save()
    return echantillon


def supprimer_echantillon(*, echantillon):
    echantillon.delete()
