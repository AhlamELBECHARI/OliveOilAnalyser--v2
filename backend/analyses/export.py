"""
Génération effective des fichiers d'export pour POST /api/analyses/export/.

Isolé de services.py pour garder la logique d'orchestration (permissions,
sélection, limite de volume) séparée du détail de mise en forme par format.
Un spectre contenant environ un millier de points, les spectres sont
toujours exportés au format long (une ligne par point) plutôt qu'une ligne
par spectre avec une colonne par longueur d'onde — ce dernier format
exploserait en largeur et serait inexploitable dans un tableur.
"""

import csv
import io
import zipfile

from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from rapports.models import Rapport
from spectres.models import Spectre

CONTENU_RESULTATS = "resultats"
CONTENU_SPECTRES = "spectres"
CONTENU_LES_DEUX = "les_deux"

CONTENU_CHOICES = [
    (CONTENU_RESULTATS, "Résultats"),
    (CONTENU_SPECTRES, "Spectres"),
    (CONTENU_LES_DEUX, "Les deux"),
]

ENTETES_RESULTATS = [
    "numero_echantillon",
    "date_analyse",
    "producteur",
    "variete",
    "region",
    "origine",
    "acidite",
    "indice_peroxyde",
    "categorie",
    "conforme",
    "date_calcul",
]

ENTETES_SPECTRES = [
    "numero_echantillon",
    "id_spectre",
    "date_acquisition",
    "longueur_onde_nm",
    "absorbance",
]


def _ligne_resultat(resultat):
    echantillon = resultat.echantillon
    return [
        echantillon.numero,
        echantillon.date_analyse.isoformat(),
        echantillon.producteur,
        echantillon.variete,
        echantillon.region,
        echantillon.origine,
        str(resultat.acidite),
        str(resultat.indice_peroxyde),
        resultat.categorie,
        "oui" if resultat.conforme else "non",
        resultat.date_calcul.isoformat(),
    ]


def _spectres_pour(queryset_resultats):
    echantillon_ids = queryset_resultats.values_list("echantillon_id", flat=True)
    return (
        Spectre.objects.filter(echantillon_id__in=list(echantillon_ids))
        .select_related("echantillon")
        .order_by("echantillon__numero", "date_acquisition")
    )


def _lignes_spectres(queryset_resultats):
    for spectre in _spectres_pour(queryset_resultats):
        for x, y in zip(spectre.valeurs_x, spectre.valeurs_y):
            yield [
                spectre.echantillon.numero,
                str(spectre.id),
                spectre.date_acquisition.isoformat(),
                x,
                y,
            ]


def _ecrire_csv_resultats(fichier_texte, queryset_resultats):
    writer = csv.writer(fichier_texte)
    writer.writerow(ENTETES_RESULTATS)
    for resultat in queryset_resultats:
        writer.writerow(_ligne_resultat(resultat))


def _ecrire_csv_spectres(fichier_texte, queryset_resultats):
    writer = csv.writer(fichier_texte)
    writer.writerow(ENTETES_SPECTRES)
    for ligne in _lignes_spectres(queryset_resultats):
        writer.writerow(ligne)


def _generer_csv(*, contenu, queryset_resultats):
    if contenu == CONTENU_LES_DEUX:
        # Un CSV n'a pas de notion d'onglet : on livre une archive contenant
        # les deux fichiers plutôt qu'un CSV hybride illisible en tableur.
        tampon = io.BytesIO()
        with zipfile.ZipFile(tampon, "w", zipfile.ZIP_DEFLATED) as archive:
            texte_resultats = io.StringIO()
            _ecrire_csv_resultats(texte_resultats, queryset_resultats)
            archive.writestr("resultats.csv", texte_resultats.getvalue())

            texte_spectres = io.StringIO()
            _ecrire_csv_spectres(texte_spectres, queryset_resultats)
            archive.writestr("spectres.csv", texte_spectres.getvalue())
        return tampon.getvalue(), "zip"

    texte = io.StringIO()
    if contenu == CONTENU_RESULTATS:
        _ecrire_csv_resultats(texte, queryset_resultats)
    else:
        _ecrire_csv_spectres(texte, queryset_resultats)
    # utf-8-sig : Excel ouvre correctement les accents sans réglage manuel.
    return texte.getvalue().encode("utf-8-sig"), "csv"


def _generer_xlsx(*, contenu, queryset_resultats):
    classeur = Workbook()
    premiere_feuille = True

    if contenu in (CONTENU_RESULTATS, CONTENU_LES_DEUX):
        feuille = classeur.active
        feuille.title = "Résultats"
        premiere_feuille = False
        feuille.append(ENTETES_RESULTATS)
        for resultat in queryset_resultats:
            feuille.append(_ligne_resultat(resultat))

    if contenu in (CONTENU_SPECTRES, CONTENU_LES_DEUX):
        feuille = classeur.active if premiere_feuille else classeur.create_sheet()
        feuille.title = "Spectres"
        feuille.append(ENTETES_SPECTRES)
        for ligne in _lignes_spectres(queryset_resultats):
            feuille.append(ligne)

    tampon = io.BytesIO()
    classeur.save(tampon)
    return tampon.getvalue(), "xlsx"


def _generer_pdf(*, queryset_resultats):
    tampon = io.BytesIO()
    document = SimpleDocTemplate(tampon, pagesize=landscape(A4))
    styles = getSampleStyleSheet()

    donnees = [
        ["Échantillon", "Variété", "Région", "Acidité", "Peroxyde", "Catégorie", "Conforme", "Date"]
    ]
    for resultat in queryset_resultats:
        echantillon = resultat.echantillon
        donnees.append(
            [
                echantillon.numero,
                echantillon.variete,
                echantillon.region,
                str(resultat.acidite),
                str(resultat.indice_peroxyde),
                resultat.categorie,
                "Oui" if resultat.conforme else "Non",
                resultat.date_calcul.strftime("%Y-%m-%d %H:%M"),
            ]
        )

    tableau = Table(donnees, repeatRows=1)
    tableau.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#3D5A3D")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTSIZE", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.grey),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F2F5F2")]),
            ]
        )
    )

    elements = [
        Paragraph("Rapport d'analyses — Olive IQ", styles["Title"]),
        Spacer(1, 0.5 * cm),
        tableau,
    ]
    document.build(elements)
    return tampon.getvalue(), "pdf"


def generer_fichier(*, rapport, contenu, format_rapport, queryset_resultats):
    """Génère le fichier d'export et l'enregistre via le storage Django
    (jamais un `open()` direct, pour rester portable si MEDIA_ROOT change de
    backend). Renvoie (chemin_relatif_enregistre, taille_en_octets)."""
    if format_rapport == Rapport.Format.PDF:
        contenu_binaire, extension = _generer_pdf(queryset_resultats=queryset_resultats)
    elif format_rapport == Rapport.Format.XLSX:
        contenu_binaire, extension = _generer_xlsx(
            contenu=contenu, queryset_resultats=queryset_resultats
        )
    else:
        contenu_binaire, extension = _generer_csv(
            contenu=contenu, queryset_resultats=queryset_resultats
        )

    chemin_relatif = f"rapports/{rapport.id}.{extension}"
    chemin_enregistre = default_storage.save(chemin_relatif, ContentFile(contenu_binaire))
    return chemin_enregistre, len(contenu_binaire)
