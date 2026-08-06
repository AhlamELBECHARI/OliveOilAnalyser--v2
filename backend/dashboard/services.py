"""
Agrégations en lecture seule pour le tableau de bord. Toute la logique et
les requêtes ORM vivent ici (annotate/aggregate/values) : jamais de
chargement de tous les enregistrements en mémoire pour les calculer côté
Python.

Classification qualité : faute d'un champ de catégorie dédié sur Resultat,
la catégorie (EVOO/VOO/Lampante) est dérivée de l'acidité libre selon les
seuils stockés dans comptes.models.Configuration (seuil_acidite_evoo,
seuil_acidite_voo) — jamais des constantes codées en dur, pour qu'un
changement de seuil dans /admin/ se répercute immédiatement ici.
"""

from datetime import timedelta

from django.db.models import Avg, Count
from django.db.models.functions import TruncDate
from django.utils import timezone

from comptes.services import obtenir_configuration
from core.qualite import LIBELLES_CATEGORIE, annotation_categorie, categorie_depuis_acidite
from echantillons.models import Echantillon
from resultats.models import Resultat

NOMBRE_ANALYSES_RECENTES = 5


def _est_administrateur(utilisateur):
    return utilisateur.role == utilisateur.Role.ADMINISTRATEUR


def _resultats_utilisateur(utilisateur):
    queryset = Resultat.objects.select_related("echantillon").all()
    if not _est_administrateur(utilisateur):
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    return queryset


def _echantillons_utilisateur(utilisateur):
    queryset = Echantillon.objects.all()
    if not _est_administrateur(utilisateur):
        queryset = queryset.filter(utilisateur=utilisateur)
    return queryset


def _variation_pourcentage(valeur_actuelle, valeur_precedente):
    if valeur_actuelle is None or not valeur_precedente:
        return None
    return round((valeur_actuelle - valeur_precedente) / valeur_precedente * 100, 1)


def _bornes_mois(reference):
    debut_mois_courant = reference.replace(
        day=1, hour=0, minute=0, second=0, microsecond=0
    )
    if debut_mois_courant.month == 1:
        debut_mois_precedent = debut_mois_courant.replace(
            year=debut_mois_courant.year - 1, month=12
        )
    else:
        debut_mois_precedent = debut_mois_courant.replace(
            month=debut_mois_courant.month - 1
        )
    return debut_mois_precedent, debut_mois_courant


def _duree_moyenne_minutes(queryset):
    """Moyenne SQL du champ réel duree_analyse_secondes. Les résultats sans
    durée enregistrée (pipeline pas encore branché) sont ignorés par Avg
    plutôt que traités comme zéro."""
    moyenne_secondes = queryset.aggregate(moyenne=Avg("duree_analyse_secondes"))["moyenne"]
    if moyenne_secondes is None:
        return None
    return round(moyenne_secondes / 60, 1)


def _serie_7_jours(queryset, aujourd_hui):
    debut = aujourd_hui - timedelta(days=6)
    comptages = (
        queryset.filter(date_calcul__date__gte=debut, date_calcul__date__lte=aujourd_hui)
        .annotate(jour=TruncDate("date_calcul"))
        .values("jour")
        .annotate(nombre_analyses=Count("id"))
    )
    comptages_par_jour = {ligne["jour"]: ligne["nombre_analyses"] for ligne in comptages}
    return [
        {
            "date": (debut + timedelta(days=i)).isoformat(),
            "nombre_analyses": comptages_par_jour.get(debut + timedelta(days=i), 0),
        }
        for i in range(7)
    ]


def _repartition_qualite(queryset, *, seuil_evoo, seuil_voo):
    total = queryset.count()
    if total == 0:
        return [
            {"categorie": cle, "libelle": libelle, "effectif": 0, "pourcentage": 0.0}
            for cle, libelle in LIBELLES_CATEGORIE.items()
        ]

    comptages = (
        queryset.annotate(categorie=annotation_categorie(seuil_evoo=seuil_evoo, seuil_voo=seuil_voo))
        .values("categorie")
        .annotate(effectif=Count("id"))
    )
    effectifs = {ligne["categorie"]: ligne["effectif"] for ligne in comptages}

    return [
        {
            "categorie": cle,
            "libelle": libelle,
            "effectif": effectifs.get(cle, 0),
            "pourcentage": round(effectifs.get(cle, 0) / total * 100, 1),
        }
        for cle, libelle in LIBELLES_CATEGORIE.items()
    ]


def _analyses_recentes(queryset, *, seuil_evoo, seuil_voo):
    resultats = queryset.select_related("echantillon").order_by("-date_calcul")[
        :NOMBRE_ANALYSES_RECENTES
    ]
    return [
        {
            "resultat_id": resultat.id,
            "numero": resultat.echantillon.numero,
            "origine": resultat.echantillon.origine,
            "variete": resultat.echantillon.variete,
            "heure": timezone.localtime(resultat.date_calcul).strftime("%H:%M"),
            "categorie": categorie_depuis_acidite(
                resultat.acidite, seuil_evoo=seuil_evoo, seuil_voo=seuil_voo
            ),
        }
        for resultat in resultats
    ]


def obtenir_statistiques(*, utilisateur):
    maintenant = timezone.now()
    aujourd_hui = maintenant.date()
    hier = aujourd_hui - timedelta(days=1)
    debut_mois_precedent, debut_mois_courant = _bornes_mois(maintenant)

    configuration = obtenir_configuration()
    seuil_evoo = configuration.seuil_acidite_evoo
    seuil_voo = configuration.seuil_acidite_voo

    resultats = _resultats_utilisateur(utilisateur)
    echantillons = _echantillons_utilisateur(utilisateur)

    resultats_mois_courant = resultats.filter(date_calcul__gte=debut_mois_courant)
    resultats_mois_precedent = resultats.filter(
        date_calcul__gte=debut_mois_precedent, date_calcul__lt=debut_mois_courant
    )

    analyses_ce_mois = resultats_mois_courant.count()
    analyses_mois_precedent = resultats_mois_precedent.count()

    analyses_aujourd_hui = resultats.filter(date_calcul__date=aujourd_hui).count()
    analyses_hier = resultats.filter(date_calcul__date=hier).count()

    echantillons_totaux = echantillons.count()
    echantillons_ce_mois = echantillons.filter(date_creation__gte=debut_mois_courant).count()

    temps_moyen_ce_mois = _duree_moyenne_minutes(resultats_mois_courant)
    temps_moyen_mois_precedent = _duree_moyenne_minutes(resultats_mois_precedent)

    return {
        "nom_utilisateur": utilisateur.nom,
        "analyses_ce_mois": {
            "valeur": analyses_ce_mois,
            "variation_pourcentage": _variation_pourcentage(
                analyses_ce_mois, analyses_mois_precedent
            ),
        },
        "echantillons_totaux": {
            "valeur": echantillons_totaux,
            "ajouts_ce_mois": echantillons_ce_mois,
        },
        "analyses_aujourd_hui": {
            "valeur": analyses_aujourd_hui,
            "variation_pourcentage": _variation_pourcentage(analyses_aujourd_hui, analyses_hier),
        },
        "temps_moyen_par_analyse_minutes": {
            "valeur": temps_moyen_ce_mois,
            "variation_pourcentage": _variation_pourcentage(
                temps_moyen_ce_mois, temps_moyen_mois_precedent
            ),
        },
        "serie_7_jours": _serie_7_jours(resultats, aujourd_hui),
        "repartition_qualite": _repartition_qualite(
            resultats_mois_courant, seuil_evoo=seuil_evoo, seuil_voo=seuil_voo
        ),
        "analyses_recentes": _analyses_recentes(
            resultats, seuil_evoo=seuil_evoo, seuil_voo=seuil_voo
        ),
    }
