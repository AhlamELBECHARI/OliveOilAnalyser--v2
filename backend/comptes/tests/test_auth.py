import re

import pytest
from django.conf import settings
from django.utils import timezone

from comptes.models import Utilisateur
from core.exceptions import CodesErreur

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
    assert response.data["code"] == CodesErreur.IDENTIFIANTS_INVALIDES
    utilisateur.refresh_from_db()
    assert utilisateur.tentatives_echouees == 1


def test_login_email_inconnu_renvoie_le_meme_code_que_mauvais_mot_de_passe(api_client):
    """Le code d'erreur ne doit jamais permettre de distinguer un email
    inconnu d'un mauvais mot de passe."""
    response = api_client.post(
        "/api/auth/login/",
        {"email": "inconnu@example.com", "password": "peu-importe"},
        format="json",
    )
    assert response.status_code == 401
    assert response.data["code"] == CodesErreur.IDENTIFIANTS_INVALIDES


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
    assert response.data["code"] == CodesErreur.COMPTE_VERROUILLE


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


def test_login_compte_desactive(api_client, utilisateur, mot_de_passe):
    utilisateur.est_actif = False
    utilisateur.save(update_fields=["est_actif"])

    response = api_client.post(
        "/api/auth/login/",
        {"email": utilisateur.email, "password": mot_de_passe},
        format="json",
    )
    assert response.status_code == 401
    assert response.data["code"] == CodesErreur.COMPTE_DESACTIVE


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


def _extraire_code(mailoutbox):
    correspondance = re.search(r"^(\d{6})$", mailoutbox[-1].body, re.MULTILINE)
    return correspondance.group(1)


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
    assert utilisateur.code_reset_mot_de_passe_hash != ""

    code_clair = _extraire_code(mailoutbox)

    reponse_verify = api_client.post(
        "/api/auth/reset-password/verify/",
        {"email": utilisateur.email, "code": code_clair},
        format="json",
    )
    assert reponse_verify.status_code == 200

    reponse_confirmation = api_client.post(
        "/api/auth/reset-password/confirm/",
        {
            "email": utilisateur.email,
            "code": code_clair,
            "nouveau_mot_de_passe": "NouveauMotDePasse123!",
        },
        format="json",
    )
    assert reponse_confirmation.status_code == 200

    utilisateur.refresh_from_db()
    assert utilisateur.check_password("NouveauMotDePasse123!")
    assert utilisateur.code_reset_mot_de_passe_hash == ""

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


def test_reset_password_mauvais_code_rejete(api_client, utilisateur, mailoutbox):
    api_client.post("/api/auth/reset-password/", {"email": utilisateur.email}, format="json")

    reponse = api_client.post(
        "/api/auth/reset-password/verify/",
        {"email": utilisateur.email, "code": "000000"},
        format="json",
    )
    assert reponse.status_code == 400
    assert reponse.data["code"] == CodesErreur.CODE_RESET_INVALIDE


def test_reset_password_code_invalide_apres_trop_de_mauvais_essais(
    api_client, utilisateur, mailoutbox, settings
):
    api_client.post("/api/auth/reset-password/", {"email": utilisateur.email}, format="json")
    code_clair = _extraire_code(mailoutbox)

    for _ in range(settings.MAX_TENTATIVES_CODE_RESET):
        api_client.post(
            "/api/auth/reset-password/verify/",
            {"email": utilisateur.email, "code": "000000"},
            format="json",
        )

    # Même le bon code est désormais refusé : il faut en redemander un.
    reponse = api_client.post(
        "/api/auth/reset-password/verify/",
        {"email": utilisateur.email, "code": code_clair},
        format="json",
    )
    assert reponse.status_code == 400
    assert reponse.data["code"] == CodesErreur.CODE_RESET_INVALIDE


def test_reset_password_code_expire_rejete(api_client, utilisateur, mailoutbox):
    api_client.post("/api/auth/reset-password/", {"email": utilisateur.email}, format="json")
    code_clair = _extraire_code(mailoutbox)

    utilisateur.refresh_from_db()
    utilisateur.code_reset_expiration = timezone.now() - timezone.timedelta(minutes=1)
    utilisateur.save(update_fields=["code_reset_expiration"])

    reponse = api_client.post(
        "/api/auth/reset-password/verify/",
        {"email": utilisateur.email, "code": code_clair},
        format="json",
    )
    assert reponse.status_code == 400
    assert reponse.data["code"] == CodesErreur.CODE_RESET_INVALIDE


def test_reset_password_limite_demandes_par_fenetre(api_client, utilisateur, settings):
    for _ in range(settings.MAX_DEMANDES_CODE_RESET_PAR_FENETRE):
        reponse = api_client.post(
            "/api/auth/reset-password/", {"email": utilisateur.email}, format="json"
        )
        assert reponse.status_code == 200

    reponse_bloquee = api_client.post(
        "/api/auth/reset-password/", {"email": utilisateur.email}, format="json"
    )
    assert reponse_bloquee.status_code == 429
    assert reponse_bloquee.data["code"] == CodesErreur.TROP_DE_DEMANDES
