import io
import uuid
import zipfile
from decimal import Decimal

import openpyxl
import pytest
from django.core.files.storage import default_storage
from django.utils import timezone
from rest_framework.test import APIClient

from echantillons.models import Echantillon
from modeles.models import Modele
from rapports.models import Rapport
from resultats.models import Resultat
from spectres.models import Spectre

pytestmark = pytest.mark.django_db


@pytest.fixture
def modele(db):
    return Modele.objects.create(
        nom="NIR-Export", version="1.0", algorithme="PLS", r2=0.9, rmsecv=0.1
    )


def _creer_resultat(*, utilisateur, modele, acidite="0.5", numero="ECH-EXP"):
    echantillon = Echantillon.objects.create(
        numero=numero, date_analyse=timezone.now(), utilisateur=utilisateur
    )
    resultat = Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite=Decimal(acidite),
        indice_peroxyde=Decimal("5.000"),
        conforme=True,
    )
    return resultat, echantillon


def _creer_spectre(echantillon):
    return Spectre.objects.create(
        echantillon=echantillon,
        valeurs_x=[1000, 1001, 1002],
        valeurs_y=[0.1, 0.2, 0.3],
        nombre_series=1,
        date_acquisition=timezone.now(),
    )


def _lire_fichier(chemin):
    with default_storage.open(chemin, "rb") as f:
        return f.read()


# --- POST /api/analyses/export/ ---


def test_export_resultats_csv(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    assert response.status_code == 201
    assert response.data["url_telechargement"] is not None
    rapport = Rapport.objects.get(pk=response.data["id"])
    assert rapport.chemin_fichier.endswith(".csv")
    assert rapport.taille and rapport.taille > 0


def test_export_spectres_format_long(client_utilisateur, utilisateur, modele):
    _, echantillon = _creer_resultat(utilisateur=utilisateur, modele=modele)
    _creer_spectre(echantillon)

    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "spectres", "format": "CSV"}, format="json"
    )
    assert response.status_code == 201

    rapport = Rapport.objects.get(pk=response.data["id"])
    lignes = _lire_fichier(rapport.chemin_fichier).decode("utf-8-sig").strip().splitlines()
    assert lignes[0] == "numero_echantillon,id_spectre,date_acquisition,longueur_onde_nm,absorbance"
    assert len(lignes) == 1 + 3  # entête + un point par (longueur d'onde, absorbance)


def test_export_les_deux_csv_produit_une_archive_zip(client_utilisateur, utilisateur, modele):
    _, echantillon = _creer_resultat(utilisateur=utilisateur, modele=modele)
    _creer_spectre(echantillon)

    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "les_deux", "format": "CSV"}, format="json"
    )
    assert response.status_code == 201

    rapport = Rapport.objects.get(pk=response.data["id"])
    assert rapport.chemin_fichier.endswith(".zip")
    archive = zipfile.ZipFile(io.BytesIO(_lire_fichier(rapport.chemin_fichier)))
    assert set(archive.namelist()) == {"resultats.csv", "spectres.csv"}


def test_export_xlsx_resultats_et_spectres_deux_feuilles(client_utilisateur, utilisateur, modele):
    _, echantillon = _creer_resultat(utilisateur=utilisateur, modele=modele)
    _creer_spectre(echantillon)

    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "les_deux", "format": "XLSX"}, format="json"
    )
    assert response.status_code == 201

    rapport = Rapport.objects.get(pk=response.data["id"])
    classeur = openpyxl.load_workbook(io.BytesIO(_lire_fichier(rapport.chemin_fichier)))
    assert classeur.sheetnames == ["Résultats", "Spectres"]


def test_export_pdf_refuse_pour_spectres(client_utilisateur):
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "spectres", "format": "PDF"}, format="json"
    )
    assert response.status_code == 400


def test_export_pdf_resultats_ok(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "PDF"}, format="json"
    )
    assert response.status_code == 201
    rapport = Rapport.objects.get(pk=response.data["id"])
    assert rapport.chemin_fichier.endswith(".pdf")


def test_export_aucune_analyse_rejete(client_utilisateur):
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    assert response.status_code == 400
    assert response.data["code"] == "aucune_analyse_a_exporter"


def test_export_limite_depassee(client_utilisateur, utilisateur, modele, monkeypatch):
    from analyses import services

    monkeypatch.setattr(services, "LIMITE_EXPORT_ANALYSES", 2)
    for i in range(3):
        _creer_resultat(utilisateur=utilisateur, modele=modele, numero=f"ECH-{i}")

    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    assert response.status_code == 400
    assert response.data["code"] == "limite_export_depassee"


def test_export_par_identifiants(client_utilisateur, utilisateur, modele):
    resultat, _ = _creer_resultat(utilisateur=utilisateur, modele=modele)
    _creer_resultat(utilisateur=utilisateur, modele=modele, numero="ECH-AUTRE")

    response = client_utilisateur.post(
        "/api/analyses/export/",
        {"contenu": "resultats", "format": "CSV", "identifiants": [str(resultat.id)]},
        format="json",
    )
    assert response.status_code == 201
    rapport = Rapport.objects.get(pk=response.data["id"])
    lignes = _lire_fichier(rapport.chemin_fichier).decode("utf-8-sig").strip().splitlines()
    assert len(lignes) == 2  # entête + le seul résultat sélectionné


def test_export_isole_par_utilisateur(client_utilisateur, autre_utilisateur, modele):
    _creer_resultat(utilisateur=autre_utilisateur, modele=modele)
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    assert response.status_code == 400
    assert response.data["code"] == "aucune_analyse_a_exporter"


def test_export_non_authentifie_refuse(api_client):
    response = api_client.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    assert response.status_code == 401


# --- GET /api/rapports/<id>/telecharger/ ---


def test_telecharger_rapport_par_son_auteur_ok(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    export_response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    response = client_utilisateur.get(f"/api/rapports/{export_response.data['id']}/telecharger/")
    assert response.status_code == 200


def test_telecharger_rapport_par_un_autre_utilisateur_refuse(
    client_utilisateur, autre_utilisateur, utilisateur, modele
):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    export_response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )

    client_autre = APIClient()
    client_autre.force_authenticate(user=autre_utilisateur)
    response = client_autre.get(f"/api/rapports/{export_response.data['id']}/telecharger/")
    assert response.status_code == 403


def test_telecharger_rapport_par_administrateur_ok(
    client_administrateur, client_utilisateur, utilisateur, modele
):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    export_response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    response = client_administrateur.get(f"/api/rapports/{export_response.data['id']}/telecharger/")
    assert response.status_code == 200


def test_telecharger_rapport_non_authentifie_refuse(api_client, client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele)
    export_response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "CSV"}, format="json"
    )
    response = api_client.get(f"/api/rapports/{export_response.data['id']}/telecharger/")
    assert response.status_code == 401


def test_telecharger_rapport_inexistant_404(client_utilisateur):
    response = client_utilisateur.get(f"/api/rapports/{uuid.uuid4()}/telecharger/")
    assert response.status_code == 404
