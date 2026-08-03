import pytest

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
