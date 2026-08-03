"""Toute la logique métier (et les requêtes ORM) pour les modèles."""

from .models import Modele


def lister_modeles():
    return Modele.objects.all()


def creer_modele(**donnees):
    return Modele.objects.create(**donnees)


def modifier_modele(*, modele, **donnees):
    for champ, valeur in donnees.items():
        setattr(modele, champ, valeur)
    modele.save()
    return modele


def supprimer_modele(*, modele):
    modele.delete()
