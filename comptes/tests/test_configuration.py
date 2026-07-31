import pytest

pytestmark = pytest.mark.django_db


def test_get_configuration_admin_ok(client_administrateur):
    response = client_administrateur.get("/api/configuration/")
    assert response.status_code == 200
    assert "seuil_conformite_acidite" in response.data


def test_get_configuration_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/configuration/")
    assert response.status_code == 403


def test_get_configuration_non_authentifie_refuse(api_client):
    response = api_client.get("/api/configuration/")
    assert response.status_code == 401


def test_put_configuration_admin_ok(client_administrateur, administrateur):
    response = client_administrateur.put(
        "/api/configuration/",
        {
            "notifications_actives": False,
            "seuil_conformite_acidite": "1.000",
            "seuil_conformite_peroxyde": "15.000",
            "est_actif": True,
        },
        format="json",
    )
    assert response.status_code == 200
    assert response.data["notifications_actives"] is False
    assert response.data["modifie_par"]["id"] == administrateur.id


def test_put_configuration_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.put(
        "/api/configuration/",
        {
            "notifications_actives": False,
            "seuil_conformite_acidite": "1.000",
            "seuil_conformite_peroxyde": "15.000",
        },
        format="json",
    )
    assert response.status_code == 403
