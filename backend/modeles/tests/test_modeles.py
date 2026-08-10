import hashlib

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile

from modeles.models import Modele

pytestmark = pytest.mark.django_db


def donnees_modele(suffixe="1"):
    return {
        "nom": f"PLS-{suffixe}",
        "version": "1.0",
        "algorithme": "PLS",
        "hyperparametres": {"n_components": 5},
        "r2": 0.95,
        "rmsecv": 0.2,
    }


def fichier_modele(nom="modele.pkl", contenu=b"contenu-binaire-factice-non-execute"):
    return SimpleUploadedFile(nom, contenu, content_type="application/octet-stream")


def donnees_modele_multipart(suffixe="1"):
    """Le multipart ne supporte pas les valeurs imbriquées : `hyperparametres`
    (JSONField) en est exclu, il reste optionnel côté serializer."""
    donnees = donnees_modele(suffixe)
    del donnees["hyperparametres"]
    return donnees


def test_lister_modeles_utilisateur_standard_autorise(client_utilisateur):
    response = client_utilisateur.get("/api/modeles/")
    assert response.status_code == 200


def test_lister_modeles_non_authentifie_refuse(api_client):
    response = api_client.get("/api/modeles/")
    assert response.status_code == 401


def test_creer_modele_admin_ok(client_administrateur):
    response = client_administrateur.post("/api/modeles/", donnees_modele("1"), format="json")
    assert response.status_code == 201


def test_creer_modele_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.post("/api/modeles/", donnees_modele("2"), format="json")
    assert response.status_code == 403


def test_creer_modele_rmsecv_negatif_rejete(client_administrateur):
    donnees = donnees_modele("3")
    donnees["rmsecv"] = -1
    response = client_administrateur.post("/api/modeles/", donnees, format="json")
    assert response.status_code == 400


def test_supprimer_modele_non_admin_refuse(client_utilisateur, client_administrateur):
    creation = client_administrateur.post("/api/modeles/", donnees_modele("4"), format="json")
    modele_id = creation.data["id"]
    response = client_utilisateur.delete(f"/api/modeles/{modele_id}/")
    assert response.status_code == 403


# --- Import de fichier de modèle ---


def test_importer_modele_avec_fichier_admin_ok(client_administrateur):
    contenu = b"contenu-binaire-factice-non-execute"
    donnees = donnees_modele_multipart("fichier-ok")
    donnees["fichier"] = fichier_modele(contenu=contenu)

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 201
    modele = Modele.objects.get(pk=response.data["id"])
    assert modele.fichier.name.endswith(".pkl")
    assert modele.empreinte_sha256 == hashlib.sha256(contenu).hexdigest()


def test_importer_modele_fichier_non_admin_refuse(client_utilisateur):
    donnees = donnees_modele_multipart("fichier-refuse")
    donnees["fichier"] = fichier_modele()

    response = client_utilisateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 403
    assert not Modele.objects.filter(nom=donnees["nom"]).exists()


def test_importer_modele_extension_non_autorisee_rejetee(client_administrateur):
    donnees = donnees_modele_multipart("extension-invalide")
    donnees["fichier"] = fichier_modele(nom="modele.exe")

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 400


def test_importer_modele_fichier_trop_volumineux_rejete(client_administrateur, monkeypatch):
    monkeypatch.setattr(Modele, "TAILLE_MAX_OCTETS", 10)
    donnees = donnees_modele_multipart("trop-gros")
    donnees["fichier"] = fichier_modele(contenu=b"x" * 100)

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 400


def test_creer_modele_sans_fichier_reste_possible(client_administrateur):
    """Le fichier reste optionnel : un modèle peut être déclaré (métadonnées
    seules) avant que le fichier entraîné ne soit disponible."""
    response = client_administrateur.post(
        "/api/modeles/", donnees_modele("sans-fichier"), format="json"
    )
    assert response.status_code == 201
    assert response.data["empreinte_sha256"] == ""
