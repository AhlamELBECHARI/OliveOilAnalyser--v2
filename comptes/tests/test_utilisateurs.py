import pytest

pytestmark = pytest.mark.django_db


def test_liste_utilisateurs_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.get("/api/utilisateurs/")
    assert response.status_code == 200


def test_liste_utilisateurs_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/utilisateurs/")
    assert response.status_code == 403


def test_liste_utilisateurs_non_authentifie_refuse(api_client):
    response = api_client.get("/api/utilisateurs/")
    assert response.status_code == 401


def test_creer_administrateur_reserve_admin(client_administrateur):
    response = client_administrateur.post(
        "/api/utilisateurs/administrateurs/",
        {
            "nom": "Nouvel Admin",
            "email": "nouvel-admin@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert response.status_code == 201
    assert response.data["role"] == "administrateur"


def test_creer_administrateur_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.post(
        "/api/utilisateurs/administrateurs/",
        {
            "nom": "Nouvel Admin",
            "email": "nouvel-admin2@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert response.status_code == 403
