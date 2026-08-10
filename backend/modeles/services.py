"""Toute la logique métier (et les requêtes ORM) pour les modèles."""

import hashlib

from .models import Modele


def lister_modeles():
    return Modele.objects.all()


def _empreinte_sha256(fichier):
    """Lit le fichier par blocs pour calculer son empreinte — jamais
    `pickle.load`/`joblib.load` : le contenu n'est jamais désérialisé."""
    hachage = hashlib.sha256()
    for bloc in fichier.chunks():
        hachage.update(bloc)
    fichier.seek(0)
    return hachage.hexdigest()


def creer_modele(*, fichier=None, **donnees):
    if fichier is not None:
        donnees["empreinte_sha256"] = _empreinte_sha256(fichier)
        donnees["fichier"] = fichier
    return Modele.objects.create(**donnees)


def modifier_modele(*, modele, fichier=None, **donnees):
    if fichier is not None:
        donnees["empreinte_sha256"] = _empreinte_sha256(fichier)
        donnees["fichier"] = fichier
    for champ, valeur in donnees.items():
        setattr(modele, champ, valeur)
    modele.save()
    return modele


def supprimer_modele(*, modele):
    modele.delete()
