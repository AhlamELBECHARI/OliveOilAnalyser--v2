import re

import pytest
from django.conf import settings
from django.utils import timezone

from comptes.models import Utilisateur

pytestmark = pytest.mark.django_db


def test_register_success(api_client):
    response = api_client.post(
        "/api/auth/register/",
        {
            "nom": "Nouvel Utilisateur",
            "email": "nouveau@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert response.status_code == 201
    assert response.data["role"] == "utilisateur"
    assert response.data["is_staff"] is False

    utilisateur = Utilisateur.objects.get(email="nouveau@example.com")
    assert utilisateur.role == Utilisateur.Role.UTILISATEUR
    assert utilisateur.is_staff is False
    assert utilisateur.is_superuser is False


def test_register_ignore_role_envoye_par_le_client(api_client):
    response = api_client.post(
        "/api/auth/register/",
        {
            "nom": "Tentative Admin",
            "email": "tentative@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
            "role": "administrateur",
            "is_staff": True,
            "is_superuser": True,
        },
        format="json",
    )
    assert response.status_code == 201
    utilisateur = Utilisateur.objects.get(email="tentative@example.com")
    assert utilisateur.role == Utilisateur.Role.UTILISATEUR
    assert utilisateur.is_staff is False
    assert utilisateur.is_superuser is False


def test_register_email_duplique_rejete(api_client, utilisateur):
    response = api_client.post(
        "/api/auth/register/",
        {
            "nom": "Doublon",
            "email": utilisateur.email,
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert response.status_code == 400


def test_login_succes(api_client, utilisateur, mot_de_passe):
    response = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    assert response.status_code == 200
    assert "access" in response.data
    assert "refresh" in response.data


def test_login_mauvais_mot_de_passe(api_client, utilisateur):
    response = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": "mauvais-mot-de-passe"},
        format="json",
    )
    assert response.status_code == 401
    utilisateur.refresh_from_db()
    assert utilisateur.tentatives_echouees == 1


def test_login_verrouillage_apres_echecs_repetes(api_client, utilisateur):
    for _ in range(settings.MAX_TENTATIVES_ECHOUEES):
        api_client.post(
            "/api/auth/login/",
            {"email": utilisateur.email, "password": "mauvais-mot-de-passe"},
            format="json",
        )

    utilisateur.refresh_from_db()
    assert utilisateur.verrouille_jusqu_a is not None

    response = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": "mauvais-mot-de-passe"},
        format="json",
    )
    assert response.status_code == 401
    assert "verrouill" in str(response.data).lower()


def test_login_deverrouillage_automatique_apres_expiration(api_client, utilisateur, mot_de_passe):
    utilisateur.tentatives_echouees = settings.MAX_TENTATIVES_ECHOUEES
    utilisateur.verrouille_jusqu_a = timezone.now() - timezone.timedelta(minutes=1)
    utilisateur.save()

    response = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    assert response.status_code == 200
    utilisateur.refresh_from_db()
    assert utilisateur.tentatives_echouees == 0
    assert utilisateur.verrouille_jusqu_a is None


def test_refresh_token(api_client, utilisateur, mot_de_passe):
    connexion = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    response = api_client.post(
        "/api/auth/refresh/", {"refresh": connexion.data["refresh"]}, format="json"
    )
    assert response.status_code == 200
    assert "access" in response.data


def test_reset_password_flow_complet_et_blackliste_anciens_tokens(
    api_client, utilisateur, mot_de_passe, mailoutbox
):
    ancienne_connexion = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    ancien_refresh = ancienne_connexion.data["refresh"]

    reponse_demande = api_client.post(
        "/api/auth/reset-password/", {"email": utilisateur.email}, format="json"
    )
    assert reponse_demande.status_code == 200
    assert len(mailoutbox) == 1

    utilisateur.refresh_from_db()
    assert utilisateur.token_reset_mot_de_passe_hash != ""

    correspondance = re.search(r"Token \(valable \d+ minutes\) : (\S+)", mailoutbox[0].body)
    token_clair = correspondance.group(1)

    reponse_confirmation = api_client.post(
        "/api/auth/reset-password/confirmer/",
        {
            "token": token_clair,
            "nouveau_mot_de_passe": "NouveauMotDePasse123!",
            "nouveau_mot_de_passe2": "NouveauMotDePasse123!",
        },
        format="json",
    )
    assert reponse_confirmation.status_code == 200

    utilisateur.refresh_from_db()
    assert utilisateur.check_password("NouveauMotDePasse123!")
    assert utilisateur.token_reset_mot_de_passe_hash == ""

    # L'ancien refresh token émis avant le reset doit désormais être blacklisté.
    reponse_refresh = api_client.post(
        "/api/auth/refresh/", {"refresh": ancien_refresh}, format="json"
    )
    assert reponse_refresh.status_code == 401


def test_reset_password_email_inconnu_ne_revele_rien(api_client, mailoutbox):
    response = api_client.post(
        "/api/auth/reset-password/", {"email": "inconnu@example.com"}, format="json"
    )
    assert response.status_code == 200
    assert len(mailoutbox) == 0
