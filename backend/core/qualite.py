"""
Classification qualité partagée entre les apps `dashboard` et `analyses`.

Faute d'un champ de catégorie dédié sur Resultat, la catégorie (EVOO/VOO/
Lampante) est dérivée de l'acidité libre selon les seuils stockés dans
comptes.models.Configuration (seuil_acidite_evoo, seuil_acidite_voo) —
jamais des constantes codées en dur, pour qu'un changement de seuil dans
/admin/ se répercute immédiatement partout où la catégorie est affichée.

Centralisé ici (plutôt que dupliqué dans chaque app) pour qu'un seul et
même calcul serve à la fois le tableau de bord et l'historique : les deux
écrans doivent toujours classer un résultat donné de la même façon.
"""

from django.db.models import Case, CharField, Value, When

CATEGORIE_EVOO = "evoo"
CATEGORIE_VOO = "voo"
CATEGORIE_LAMPANTE = "lampante"

LIBELLES_CATEGORIE = {
    CATEGORIE_EVOO: "Extra Vierge (EVOO)",
    CATEGORIE_VOO: "Vierge (VOO)",
    CATEGORIE_LAMPANTE: "Lampante",
}


def categorie_depuis_acidite(acidite, *, seuil_evoo, seuil_voo):
    if acidite <= seuil_evoo:
        return CATEGORIE_EVOO
    if acidite <= seuil_voo:
        return CATEGORIE_VOO
    return CATEGORIE_LAMPANTE


def annotation_categorie(*, seuil_evoo, seuil_voo, champ_acidite="acidite"):
    """Expression `Case/When` réutilisable pour annoter un queryset de
    Resultat avec sa catégorie qualité, filtrable/groupable en base."""
    return Case(
        When(**{f"{champ_acidite}__lte": seuil_evoo}, then=Value(CATEGORIE_EVOO)),
        When(**{f"{champ_acidite}__lte": seuil_voo}, then=Value(CATEGORIE_VOO)),
        default=Value(CATEGORIE_LAMPANTE),
        output_field=CharField(),
    )
