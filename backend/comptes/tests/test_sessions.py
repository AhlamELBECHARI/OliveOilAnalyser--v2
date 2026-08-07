import pytest
from rest_framework_simplejwt.tokens import RefreshToken

pytestmark = pytest.mark.django_db


def _connecter(api_client, utilisateur, mot_de_passe):
    reponse = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {reponse.data['access']}")
    return reponse.data


def test_lister_sessions_apres_connexion(api_client, utilisateur, mot_de_passe):
    connexion = _connecter(api_client, utilisateur, mot_de_passe)
    jti_courant = RefreshToken(connexion["refresh"])["jti"]

    reponse = api_client.get(f"/api/auth/sessions/?jti_courant={jti_courant}")
    assert reponse.status_code == 200
    assert len(reponse.data) == 1
    assert reponse.data[0]["est_courante"] is True


def test_lister_sessions_sans_jti_courant_aucune_marquee_courante(
    api_client, utilisateur, mot_de_passe
):
    _connecter(api_client, utilisateur, mot_de_passe)

    reponse = api_client.get("/api/auth/sessions/")
    assert reponse.status_code == 200
    assert all(session["est_courante"] is False for session in reponse.data)


def test_lister_sessions_isole_par_utilisateur(
    api_client, utilisateur, autre_utilisateur, mot_de_passe
):
    _connecter(api_client, autre_utilisateur, mot_de_passe)

    reponse = api_client.get("/api/auth/sessions/")
    assert reponse.status_code == 200
    assert len(reponse.data) == 1


def test_lister_sessions_non_authentifie_refuse(api_client):
    response = api_client.get("/api/auth/sessions/")
    assert response.status_code == 401


def test_revoquer_session(api_client, utilisateur, mot_de_passe):
    connexion = _connecter(api_client, utilisateur, mot_de_passe)
    session_id = api_client.get("/api/auth/sessions/").data[0]["id"]

    reponse = api_client.delete(f"/api/auth/sessions/{session_id}/")
    assert reponse.status_code == 204

    # Le refresh token de la session révoquée est désormais blacklisté.
    api_client.credentials()
    reponse_refresh = api_client.post(
        "/api/auth/refresh/", {"refresh": connexion["refresh"]}, format="json"
    )
    assert reponse_refresh.status_code == 401


def test_revoquer_session_dautrui_introuvable(
    api_client, utilisateur, autre_utilisateur, mot_de_passe
):
    _connecter(api_client, autre_utilisateur, mot_de_passe)
    session_autre_id = api_client.get("/api/auth/sessions/").data[0]["id"]

    _connecter(api_client, utilisateur, mot_de_passe)
    reponse = api_client.delete(f"/api/auth/sessions/{session_autre_id}/")
    assert reponse.status_code == 404
