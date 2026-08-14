"""
Agrégations et recherche en lecture seule pour l'écran Historique. Comme
`dashboard`, cette app ne possède aucun modèle propre : elle ne fait que
requêter Resultat/Echantillon, et tout le filtrage/tri/recherche se fait
en base (ORM), jamais en mémoire côté Python ni côté mobile.
"""

from datetime import timedelta

from django.db.models import Avg, Count, Max, Min, Q
from django.db.models.functions import TruncDate
from django.utils import timezone

from comptes.services import obtenir_configuration
from core.exceptions import AucuneAnalyseAExporterError, LimiteExportDepasseeError
from core.qualite import LIBELLES_CATEGORIE, annotation_categorie
from rapports.models import Rapport
from resultats.models import Resultat

from . import export as export_fichiers

# Un spectre pèse ~1000 points : au-delà de cette limite, l'export
# risquerait de dépasser le temps de requête HTTP plutôt que d'échouer
# proprement. Le message renvoyé indique explicitement le nombre demandé et
# la limite, pour que l'utilisateur affine ses filtres plutôt que de
# rencontrer un timeout muet.
LIMITE_EXPORT_ANALYSES = 500

# Fenêtre des indicateurs "tendance" (acidité moyenne, meilleure/plus forte
# acidité) : 14 jours glissants, comparés aux 14 jours précédents.
NOMBRE_JOURS_TENDANCE = 14
# Fenêtre de l'indicateur "analyses / jour" : 30 derniers jours, comme
# affiché dans la maquette ("30 derniers jours").
NOMBRE_JOURS_FREQUENCE = 30

TRIS_AUTORISES = {
    "date_calcul",
    "-date_calcul",
    "acidite",
    "-acidite",
    "indice_peroxyde",
    "-indice_peroxyde",
}


def _est_administrateur(utilisateur):
    return utilisateur.role == utilisateur.Role.ADMINISTRATEUR


def _resultats_utilisateur(utilisateur):
    """Un utilisateur standard ne voit que les résultats de ses propres
    échantillons ; un administrateur voit tout — même règle que dans
    dashboard.services, resultats.services et echantillons.services."""
    queryset = Resultat.objects.select_related("echantillon", "echantillon__utilisateur").all()
    if not _est_administrateur(utilisateur):
        queryset = queryset.filter(echantillon__utilisateur=utilisateur)
    return queryset


def _annoter_categorie(queryset):
    configuration = obtenir_configuration()
    return queryset.annotate(
        categorie=annotation_categorie(
            seuil_evoo=configuration.seuil_acidite_evoo,
            seuil_voo=configuration.seuil_acidite_voo,
        )
    )


def _variation_pourcentage(valeur_actuelle, valeur_precedente):
    if valeur_actuelle is None or not valeur_precedente:
        return None
    return round((valeur_actuelle - valeur_precedente) / valeur_precedente * 100, 1)


def rechercher_historique(
    *,
    utilisateur,
    recherche=None,
    qualite=None,
    variete=None,
    region=None,
    operateur=None,
    date_debut=None,
    date_fin=None,
    tri=None,
):
    """Queryset annoté de la catégorie qualité, filtré/trié entièrement en
    base pour GET /api/analyses/historique/. `operateur` n'a d'effet réel
    que pour un administrateur (déjà non filtré par auteur) — pour un
    utilisateur standard, déjà limité à ses propres résultats, il ne fait
    que re-filtrer sur lui-même sans rien exposer d'autrui."""
    queryset = _annoter_categorie(_resultats_utilisateur(utilisateur))

    if recherche:
        queryset = queryset.filter(
            Q(echantillon__numero__icontains=recherche)
            | Q(echantillon__producteur__icontains=recherche)
            | Q(echantillon__variete__icontains=recherche)
            | Q(echantillon__region__icontains=recherche)
        )
    if qualite:
        queryset = queryset.filter(categorie=qualite)
    if variete:
        queryset = queryset.filter(echantillon__variete__iexact=variete)
    if region:
        queryset = queryset.filter(echantillon__region__iexact=region)
    if operateur:
        queryset = queryset.filter(echantillon__utilisateur_id=operateur)
    if date_debut:
        queryset = queryset.filter(date_calcul__date__gte=date_debut)
    if date_fin:
        queryset = queryset.filter(date_calcul__date__lte=date_fin)

    return queryset.order_by(tri if tri in TRIS_AUTORISES else "-date_calcul")


def _serie_quotidienne(queryset, *, jours, agregat, champ_valeur):
    """Série [{date, valeur}] sur les `jours` derniers jours (un point par
    jour, calculé en base via TruncDate + agrégat), pour alimenter les
    mini-graphiques de tendance côté mobile."""
    aujourd_hui = timezone.now().date()
    debut = aujourd_hui - timedelta(days=jours - 1)
    lignes = (
        queryset.filter(date_calcul__date__gte=debut, date_calcul__date__lte=aujourd_hui)
        .annotate(jour=TruncDate("date_calcul"))
        .values("jour")
        .annotate(valeur=agregat(champ_valeur))
    )
    valeurs_par_jour = {ligne["jour"]: ligne["valeur"] for ligne in lignes}
    return [
        {
            "date": (debut + timedelta(days=i)).isoformat(),
            "valeur": valeurs_par_jour.get(debut + timedelta(days=i)),
        }
        for i in range(jours)
    ]


def _compte_mois(queryset, annee, mois):
    return queryset.filter(date_calcul__year=annee, date_calcul__month=mois).count()


def _mois_precedent(annee, mois):
    if mois == 1:
        return annee - 1, 12
    return annee, mois - 1


def obtenir_apercu(*, utilisateur):
    """Les 5 indicateurs de la carte "Aperçu" : total, répartition qualité
    (toutes périodes confondues) et nombre d'analyses ce mois-ci."""
    configuration = obtenir_configuration()
    queryset = _resultats_utilisateur(utilisateur)
    total = queryset.count()

    if total == 0:
        repartition = [
            {"categorie": cle, "libelle": libelle, "effectif": 0, "pourcentage": 0.0}
            for cle, libelle in LIBELLES_CATEGORIE.items()
        ]
    else:
        comptages = (
            queryset.annotate(
                categorie=annotation_categorie(
                    seuil_evoo=configuration.seuil_acidite_evoo,
                    seuil_voo=configuration.seuil_acidite_voo,
                )
            )
            .values("categorie")
            .annotate(effectif=Count("id"))
        )
        effectifs = {ligne["categorie"]: ligne["effectif"] for ligne in comptages}
        repartition = [
            {
                "categorie": cle,
                "libelle": libelle,
                "effectif": effectifs.get(cle, 0),
                "pourcentage": round(effectifs.get(cle, 0) / total * 100, 1),
            }
            for cle, libelle in LIBELLES_CATEGORIE.items()
        ]

    aujourd_hui = timezone.now().date()
    annee_precedente, mois_precedent = _mois_precedent(aujourd_hui.year, aujourd_hui.month)
    analyses_ce_mois = _compte_mois(queryset, aujourd_hui.year, aujourd_hui.month)
    analyses_mois_precedent = _compte_mois(queryset, annee_precedente, mois_precedent)

    return {
        "total_analyses": total,
        "repartition_qualite": repartition,
        "ce_mois": {
            "valeur": analyses_ce_mois,
            "variation_pourcentage": _variation_pourcentage(
                analyses_ce_mois, analyses_mois_precedent
            ),
        },
    }


def obtenir_statistiques_rapides(*, utilisateur):
    """Les 4 indicateurs de bas de page de l'écran Historique, chacun
    calculé par agrégation ORM (jamais de valeur en dur)."""
    queryset = _resultats_utilisateur(utilisateur)
    aujourd_hui = timezone.now().date()

    debut_periode = aujourd_hui - timedelta(days=NOMBRE_JOURS_TENDANCE - 1)
    debut_periode_precedente = debut_periode - timedelta(days=NOMBRE_JOURS_TENDANCE)
    fin_periode_precedente = debut_periode - timedelta(days=1)

    fenetre_actuelle = queryset.filter(
        date_calcul__date__gte=debut_periode, date_calcul__date__lte=aujourd_hui
    )
    fenetre_precedente = queryset.filter(
        date_calcul__date__gte=debut_periode_precedente,
        date_calcul__date__lte=fin_periode_precedente,
    )

    moyenne_actuelle = fenetre_actuelle.aggregate(v=Avg("acidite"))["v"]
    moyenne_precedente = fenetre_precedente.aggregate(v=Avg("acidite"))["v"]
    bornes = fenetre_actuelle.aggregate(minimum=Min("acidite"), maximum=Max("acidite"))

    debut_frequence = aujourd_hui - timedelta(days=NOMBRE_JOURS_FREQUENCE - 1)
    nombre_sur_periode = queryset.filter(
        date_calcul__date__gte=debut_frequence, date_calcul__date__lte=aujourd_hui
    ).count()
    moyenne_par_jour = round(nombre_sur_periode / NOMBRE_JOURS_FREQUENCE, 1)

    return {
        "apercu": obtenir_apercu(utilisateur=utilisateur),
        "tendance_acidite_moyenne": {
            "valeur": round(moyenne_actuelle, 3) if moyenne_actuelle is not None else None,
            "variation_pourcentage": _variation_pourcentage(moyenne_actuelle, moyenne_precedente),
            "serie": _serie_quotidienne(
                queryset, jours=NOMBRE_JOURS_TENDANCE, agregat=Avg, champ_valeur="acidite"
            ),
        },
        "meilleure_qualite": {
            "valeur": bornes["minimum"],
            "variation_pourcentage": None,
            "serie": _serie_quotidienne(
                queryset, jours=NOMBRE_JOURS_TENDANCE, agregat=Min, champ_valeur="acidite"
            ),
        },
        "plus_forte_acidite": {
            "valeur": bornes["maximum"],
            "variation_pourcentage": None,
            "serie": _serie_quotidienne(
                queryset, jours=NOMBRE_JOURS_TENDANCE, agregat=Max, champ_valeur="acidite"
            ),
        },
        "analyses_par_jour": {
            "valeur": moyenne_par_jour,
            "variation_pourcentage": None,
            "serie": _serie_quotidienne(
                queryset, jours=NOMBRE_JOURS_FREQUENCE, agregat=Count, champ_valeur="id"
            ),
        },
    }


def declencher_export(
    *,
    utilisateur,
    contenu,
    format_rapport,
    identifiants=None,
    recherche=None,
    qualite=None,
    variete=None,
    region=None,
    operateur=None,
    date_debut=None,
    date_fin=None,
):
    """Sélectionne les résultats concernés (par identifiants explicites ou
    par les mêmes filtres que l'historique — voir l'export global de
    l'espace admin, qui réutilise ce même mécanisme sans filtre auteur pour
    un administrateur), génère réellement le fichier et l'associe au
    Rapport créé pour tracer qui a exporté quoi et quand."""
    if identifiants:
        queryset = _annoter_categorie(_resultats_utilisateur(utilisateur)).filter(
            id__in=identifiants
        )
    else:
        queryset = rechercher_historique(
            utilisateur=utilisateur,
            recherche=recherche,
            qualite=qualite,
            variete=variete,
            region=region,
            operateur=operateur,
            date_debut=date_debut,
            date_fin=date_fin,
        )

    nombre = queryset.count()
    if nombre == 0:
        raise AucuneAnalyseAExporterError()
    if nombre > LIMITE_EXPORT_ANALYSES:
        raise LimiteExportDepasseeError(
            f"Cette exportation porte sur {nombre} analyses, ce qui dépasse la "
            f"limite de {LIMITE_EXPORT_ANALYSES} analyses par export. Affinez "
            f"vos filtres ou réduisez votre sélection."
        )

    rapport = Rapport.objects.create(genere_par=utilisateur, format=format_rapport, chemin_fichier="")
    chemin, taille = export_fichiers.generer_fichier(
        rapport=rapport,
        contenu=contenu,
        format_rapport=format_rapport,
        queryset_resultats=queryset,
    )
    rapport.chemin_fichier = chemin
    rapport.taille = taille
    rapport.save(update_fields=["chemin_fichier", "taille"])
    return rapport
