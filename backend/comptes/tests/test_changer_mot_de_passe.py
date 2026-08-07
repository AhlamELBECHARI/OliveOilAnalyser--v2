import pytest

from core.exceptions import CodesErreur

pytestmark = pytest.mark.django_db


def test_changer_mot_de_passe_succes(client_utilisateur, utilisateur, mot_de_passe):
    response = client_utilisateur.post(
        "/api/auth/changer-mot-de-passe/",
        {"ancien_mot_de_passe": mot_de_passe, "nouveau_mot_de_passe": "NouveauMotDePasse123!"},
        format="json",
    )
    assert response.status_code == 200

    utilisateur.refresh_from_db()
    assert utilisateur.check_password("NouveauMotDePasse123!")


def test_changer_mot_de_passe_ancien_incorrect_rejete(client_utilisateur, utilisateur, mot_de_passe):
    response = client_utilisateur.post(
        "/api/auth/changer-mot-de-passe/",
        {"ancien_mot_de_passe": "mauvais-mot-de-passe", "nouveau_mot_de_passe": "Autre123456!"},
        format="json",
    )
    assert response.status_code == 400
    assert response.data["code"] == CodesErreur.MOT_DE_PASSE_ACTUEL_INVALIDE

    utilisateur.refresh_from_db()
    assert utilisateur.check_password(mot_de_passe)


def test_changer_mot_de_passe_non_authentifie_refuse(api_client):
    response = api_client.post(
        "/api/auth/changer-mot-de-passe/",
        {"ancien_mot_de_passe": "peu-importe", "nouveau_mot_de_passe": "Autre123456!"},
        format="json",
    )
    assert response.status_code == 401


def test_changer_mot_de_passe_blackliste_les_refresh_tokens_existants(
    api_client, utilisateur, mot_de_passe
):
    connexion = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    ancien_refresh = connexion.data["refresh"]

    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {connexion.data['access']}")
    reponse = api_client.post(
        "/api/auth/changer-mot-de-passe/",
        {"ancien_mot_de_passe": mot_de_passe, "nouveau_mot_de_passe": "NouveauMotDePasse123!"},
        format="json",
    )
    assert reponse.status_code == 200

    api_client.credentials()
    reponse_refresh = api_client.post(
        "/api/auth/refresh/", {"refresh": ancien_refresh}, format="json"
    )
    assert reponse_refresh.status_code == 401
