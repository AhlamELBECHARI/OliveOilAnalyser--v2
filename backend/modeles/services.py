"""Toute la logique métier (et les requêtes ORM) pour les modèles."""

import hashlib

from django.db import transaction
from django.db.models import Count, Max

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


def _liberer_reference_existante(*, grandeur_predite, exclure_pk=None):
    """Un seul modèle de référence actif par grandeur prédite (voir aussi la
    contrainte d'unicité partielle en base) : doit tourner AVANT
    l'insertion/l'enregistrement du nouveau, sinon la contrainte partielle
    (un seul est_reference=True par grandeur) est violée en base avant même
    d'avoir pu libérer l'ancien."""
    queryset = Modele.objects.filter(grandeur_predite=grandeur_predite, est_reference=True)
    if exclure_pk is not None:
        queryset = queryset.exclude(pk=exclure_pk)
    queryset.update(est_reference=False)


@transaction.atomic
def creer_modele(*, fichier=None, **donnees):
    if fichier is not None:
        donnees["empreinte_sha256"] = _empreinte_sha256(fichier)
        donnees["fichier"] = fichier
    if donnees.get("est_reference"):
        grandeur = donnees.get(
            "grandeur_predite", Modele._meta.get_field("grandeur_predite").default
        )
        _liberer_reference_existante(grandeur_predite=grandeur)
    return Modele.objects.create(**donnees)


@transaction.atomic
def modifier_modele(*, modele, acteur=None, fichier=None, **donnees):
    if fichier is not None:
        donnees["empreinte_sha256"] = _empreinte_sha256(fichier)
        donnees["fichier"] = fichier
    if donnees.get("est_reference"):
        grandeur = donnees.get("grandeur_predite", modele.grandeur_predite)
        _liberer_reference_existante(grandeur_predite=grandeur, exclure_pk=modele.pk)

    # Capturé AVANT mutation : c'est le passage explicite à True qui doit
    # être journalisé, pas la simple présence du champ dans la requête (un
    # PATCH peut renvoyer une valeur déjà en place, ex. le formulaire admin
    # qui republie tous les champs).
    devient_deprecie = "est_deprecie" in donnees and donnees["est_deprecie"] and not modele.est_deprecie
    est_reactive = "est_deprecie" in donnees and not donnees["est_deprecie"] and modele.est_deprecie
    devient_reference = "est_reference" in donnees and donnees["est_reference"] and not modele.est_reference

    for champ, valeur in donnees.items():
        setattr(modele, champ, valeur)
    modele.save()

    _journaliser_modification(
        modele=modele,
        acteur=acteur,
        devient_deprecie=devient_deprecie,
        est_reactive=est_reactive,
        devient_reference=devient_reference,
    )
    return modele


def _journaliser_modification(*, modele, acteur, devient_deprecie, est_reactive, devient_reference):
    from administration.models import JournalAudit
    from administration.services import enregistrer_action

    if devient_deprecie:
        enregistrer_action(
            action=JournalAudit.Action.DEPRECIATION_MODELE,
            acteur=acteur,
            cible_type="Modele",
            cible_id=modele.pk,
        )
    if est_reactive:
        enregistrer_action(
            action=JournalAudit.Action.REACTIVATION_MODELE,
            acteur=acteur,
            cible_type="Modele",
            cible_id=modele.pk,
        )
    if devient_reference:
        enregistrer_action(
            action=JournalAudit.Action.DEFINITION_MODELE_REFERENCE,
            acteur=acteur,
            cible_type="Modele",
            cible_id=modele.pk,
            details={"grandeur_predite": modele.grandeur_predite},
        )


def supprimer_modele(*, modele, acteur=None):
    from administration.models import JournalAudit
    from administration.services import enregistrer_action

    modele_id = modele.pk
    modele_nom = str(modele)
    modele.delete()
    enregistrer_action(
        action=JournalAudit.Action.SUPPRESSION_MODELE,
        acteur=acteur,
        cible_type="Modele",
        cible_id=modele_id,
        details={"nom": modele_nom},
    )


def historique_utilisation(*, modele):
    """Nombre de résultats produits par ce modèle (une prédiction = une
    évaluation réelle d'un scan par ce modèle, qu'il soit ou non le modèle
    de référence retenu) et date de sa dernière utilisation — voir l'action
    admin "Consulter l'historique d'utilisation"."""
    agregat = modele.predictions.aggregate(nombre=Count("id"), derniere=Max("date_creation"))
    return {
        "nombre_resultats": agregat["nombre"] or 0,
        "derniere_utilisation": agregat["derniere"],
    }
