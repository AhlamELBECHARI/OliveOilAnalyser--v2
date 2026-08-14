"""Toute la logique métier (et les requêtes ORM) pour les résultats."""

from django.db import transaction
from rest_framework.exceptions import PermissionDenied

from comptes.services import obtenir_configuration
from modeles.models import GrandeurPredite, TypeModele

from .models import PredictionModele, Resultat


def lister_resultats(*, utilisateur):
    """Un utilisateur standard ne voit que les résultats de ses propres
    échantillons ; un administrateur voit tout."""
    queryset = Resultat.objects.select_related(
        "echantillon", "echantillon__utilisateur", "modele_utilise", "valide_par"
    ).prefetch_related("predictions__modele").all()
    if utilisateur.role != utilisateur.Role.ADMINISTRATEUR:
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    return queryset


def _verifier_acces_echantillon(*, utilisateur, echantillon):
    if (
        utilisateur.role != utilisateur.Role.ADMINISTRATEUR
        and echantillon.utilisateur_id != utilisateur.id
    ):
        raise PermissionDenied("Vous n'avez pas accès à cet échantillon.")


def _creer_predictions(*, resultat, predictions):
    PredictionModele.objects.bulk_create(
        PredictionModele(resultat=resultat, **prediction) for prediction in predictions
    )


def _deriver_synthese_depuis_predictions(*, resultat):
    """Recopie sur Resultat la prédiction du modèle marqué `est_reference`
    pour acidite/indice_peroxyde, puis recalcule `conforme` en conséquence —
    voir modeles.services._appliquer_reference_exclusive pour la bascule de
    ce marqueur. Si aucun modèle de référence n'a de prédiction ici, les
    valeurs fournies directement par le client à la création sont
    conservées telles quelles (comportement historique inchangé)."""
    champs_modifies = []

    prediction_acidite = (
        resultat.predictions.filter(
            modele__type_modele=TypeModele.REGRESSION,
            modele__grandeur_predite=GrandeurPredite.ACIDITE,
            modele__est_reference=True,
        )
        .exclude(valeur_numerique__isnull=True)
        .select_related("modele")
        .first()
    )
    if prediction_acidite is not None:
        resultat.acidite = prediction_acidite.valeur_numerique
        resultat.modele_utilise = prediction_acidite.modele
        champs_modifies += ["acidite", "modele_utilise"]

    prediction_peroxyde = (
        resultat.predictions.filter(
            modele__type_modele=TypeModele.REGRESSION,
            modele__grandeur_predite=GrandeurPredite.INDICE_PEROXYDE,
            modele__est_reference=True,
        )
        .exclude(valeur_numerique__isnull=True)
        .first()
    )
    if prediction_peroxyde is not None:
        resultat.indice_peroxyde = prediction_peroxyde.valeur_numerique
        champs_modifies.append("indice_peroxyde")

    if champs_modifies:
        configuration = obtenir_configuration()
        resultat.conforme = (
            resultat.acidite <= configuration.seuil_conformite_acidite
            and resultat.indice_peroxyde <= configuration.seuil_conformite_peroxyde
        )
        champs_modifies.append("conforme")
        resultat.save(update_fields=champs_modifies)


@transaction.atomic
def creer_resultat(*, utilisateur, echantillon, predictions=None, **donnees):
    _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=echantillon)
    donnees["numero_replicat"] = Resultat.objects.filter(echantillon=echantillon).count() + 1
    resultat = Resultat.objects.create(echantillon=echantillon, **donnees)
    if predictions:
        _creer_predictions(resultat=resultat, predictions=predictions)
        _deriver_synthese_depuis_predictions(resultat=resultat)
    return resultat


def modifier_resultat(*, utilisateur, resultat, predictions=None, **donnees):
    nouvel_echantillon = donnees.get("echantillon")
    if nouvel_echantillon is not None:
        _verifier_acces_echantillon(utilisateur=utilisateur, echantillon=nouvel_echantillon)
    for champ, valeur in donnees.items():
        setattr(resultat, champ, valeur)
    resultat.save()
    return resultat


def supprimer_resultat(*, resultat):
    resultat.delete()
