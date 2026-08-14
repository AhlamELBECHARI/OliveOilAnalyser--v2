import pytest

from administration.models import JournalAudit
from comptes.models import Utilisateur

pytestmark = pytest.mark.django_db


@pytest.fixture
def second_administrateur(db, mot_de_passe):
    return Utilisateur.objects.create_user(
        email="admin2@example.com",
        nom="Second Admin",
        password=mot_de_passe,
        role=Utilisateur.Role.ADMINISTRATEUR,
        is_staff=True,
    )


# --- Accès ---


def test_lister_utilisateurs_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.get("/api/admin/utilisateurs/")
    assert response.status_code == 200
    assert response.data["count"] >= 1


def test_lister_utilisateurs_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/admin/utilisateurs/")
    assert response.status_code == 403


def test_lister_utilisateurs_non_authentifie_refuse(api_client):
    response = api_client.get("/api/admin/utilisateurs/")
    assert response.status_code == 401


def test_lister_utilisateurs_recherche_par_email(client_administrateur, utilisateur):
    response = client_administrateur.get(f"/api/admin/utilisateurs/?recherche={utilisateur.email}")
    assert response.status_code == 200
    assert any(u["id"] == utilisateur.id for u in response.data["results"])


def test_detail_utilisateur_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.get(f"/api/admin/utilisateurs/{utilisateur.id}/")
    assert response.status_code == 200
    assert response.data["nombre_analyses"] == 0


def test_detail_utilisateur_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.get(f"/api/admin/utilisateurs/{autre_utilisateur.id}/")
    assert response.status_code == 403


# --- Création de compte ---


def test_creer_utilisateur_admin_ok(client_administrateur):
    response = client_administrateur.post(
        "/api/admin/utilisateurs/",
        {
            "nom": "Nouveau",
            "email": "nouveau@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
            "role": "utilisateur",
        },
        format="json",
    )
    assert response.status_code == 201
    assert response.data["role"] == "utilisateur"


def test_creer_administrateur_via_admin_ok(client_administrateur):
    response = client_administrateur.post(
        "/api/admin/utilisateurs/",
        {
            "nom": "Nouvel Admin",
            "email": "nouvel-admin@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
            "role": "administrateur",
        },
        format="json",
    )
    assert response.status_code == 201
    assert response.data["role"] == "administrateur"


def test_creer_utilisateur_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.post(
        "/api/admin/utilisateurs/",
        {
            "nom": "Nouveau",
            "email": "nouveau2@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert response.status_code == 403


def test_creer_utilisateur_journalise(client_administrateur):
    client_administrateur.post(
        "/api/admin/utilisateurs/",
        {
            "nom": "Traceable",
            "email": "traceable@example.com",
            "password": "MotDePasse123!",
            "password2": "MotDePasse123!",
        },
        format="json",
    )
    assert JournalAudit.objects.filter(action=JournalAudit.Action.CREATION_COMPTE).exists()


# --- Changement de rôle ---


def test_changer_role_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{utilisateur.id}/role/",
        {"role": "administrateur"},
        format="json",
    )
    assert response.status_code == 200
    assert response.data["role"] == "administrateur"
    assert JournalAudit.objects.filter(action=JournalAudit.Action.CHANGEMENT_ROLE).exists()


def test_changer_role_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.patch(
        f"/api/admin/utilisateurs/{autre_utilisateur.id}/role/",
        {"role": "administrateur"},
        format="json",
    )
    assert response.status_code == 403


def test_changer_son_propre_role_refuse(client_administrateur, administrateur, second_administrateur):
    """Garde-fou : un administrateur ne peut pas se retirer son propre rôle."""
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{administrateur.id}/role/",
        {"role": "utilisateur"},
        format="json",
    )
    assert response.status_code == 400
    assert response.data["code"] == "auto_modification_interdite"


def test_retrograder_dernier_administrateur_refuse(
    client_administrateur, administrateur, second_administrateur
):
    """Garde-fou : impossible de retirer le rôle admin au dernier
    administrateur actif restant (ici via un autre admin qui rétrograde
    `administrateur` en premier, pour isoler ce garde-fou de
    l'auto-modification — voir test_changer_son_propre_role_refuse)."""
    from rest_framework.test import APIClient

    client_second = APIClient()
    client_second.force_authenticate(user=second_administrateur)

    # 2 admins actifs -> le second peut rétrograder `administrateur`.
    reponse_1 = client_second.patch(
        f"/api/admin/utilisateurs/{administrateur.id}/role/", {"role": "utilisateur"}, format="json"
    )
    assert reponse_1.status_code == 200

    # Il ne reste plus que second_administrateur comme admin actif en base :
    # client_administrateur (authentifié comme `administrateur`, désormais
    # simple utilisateur en base — seul son pk compte pour ce test) essaie
    # de rétrograder ce dernier admin restant.
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{second_administrateur.id}/role/",
        {"role": "utilisateur"},
        format="json",
    )
    assert response.status_code == 400
    assert response.data["code"] == "dernier_administrateur"


# --- Activation / désactivation ---


def test_desactiver_compte_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{utilisateur.id}/activation/", {"actif": False}, format="json"
    )
    assert response.status_code == 200
    assert response.data["est_actif"] is False
    assert JournalAudit.objects.filter(action=JournalAudit.Action.DESACTIVATION_COMPTE).exists()


def test_desactiver_compte_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.patch(
        f"/api/admin/utilisateurs/{autre_utilisateur.id}/activation/", {"actif": False}, format="json"
    )
    assert response.status_code == 403


def test_auto_desactivation_refusee(client_administrateur, administrateur, second_administrateur):
    """Garde-fou : un administrateur ne peut pas désactiver son propre compte."""
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{administrateur.id}/activation/", {"actif": False}, format="json"
    )
    assert response.status_code == 400
    assert response.data["code"] == "auto_modification_interdite"


def test_desactiver_dernier_administrateur_refuse(client_administrateur, administrateur, second_administrateur):
    """Garde-fou : impossible de désactiver le dernier administrateur actif
    (ici via un autre admin, pour isoler ce garde-fou de l'auto-désactivation)."""
    from rest_framework.test import APIClient

    client_second = APIClient()
    client_second.force_authenticate(user=second_administrateur)

    # 2 admins actifs -> désactiver `administrateur` doit réussir.
    reponse_1 = client_second.patch(
        f"/api/admin/utilisateurs/{administrateur.id}/activation/", {"actif": False}, format="json"
    )
    assert reponse_1.status_code == 200

    # Il ne reste plus que second_administrateur actif : le désactiver doit échouer.
    response = client_administrateur.patch(
        f"/api/admin/utilisateurs/{second_administrateur.id}/activation/",
        {"actif": False},
        format="json",
    )
    assert response.status_code == 400
    assert response.data["code"] == "dernier_administrateur"


# --- Déverrouillage ---


def test_deverrouiller_compte_admin_ok(client_administrateur, utilisateur):
    utilisateur.tentatives_echouees = 5
    from django.utils import timezone
    from datetime import timedelta

    utilisateur.verrouille_jusqu_a = timezone.now() + timedelta(minutes=30)
    utilisateur.save()

    response = client_administrateur.post(f"/api/admin/utilisateurs/{utilisateur.id}/deverrouiller/")
    assert response.status_code == 200
    assert response.data["tentatives_echouees"] == 0
    assert response.data["verrouille_jusqu_a"] is None


def test_deverrouiller_compte_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.post(f"/api/admin/utilisateurs/{autre_utilisateur.id}/deverrouiller/")
    assert response.status_code == 403


# --- Réinitialisation de mot de passe déclenchée par un admin ---


def test_reset_mot_de_passe_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.post(
        f"/api/admin/utilisateurs/{utilisateur.id}/reset-mot-de-passe/"
    )
    assert response.status_code == 200
    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.RESET_MOT_DE_PASSE_DECLENCHE
    ).exists()


def test_reset_mot_de_passe_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.post(
        f"/api/admin/utilisateurs/{autre_utilisateur.id}/reset-mot-de-passe/"
    )
    assert response.status_code == 403


# --- Sessions d'un autre utilisateur ---


def test_lister_sessions_admin_ok(client_administrateur, utilisateur):
    response = client_administrateur.get(f"/api/admin/utilisateurs/{utilisateur.id}/sessions/")
    assert response.status_code == 200


def test_lister_sessions_non_admin_refuse(client_utilisateur, autre_utilisateur):
    response = client_utilisateur.get(f"/api/admin/utilisateurs/{autre_utilisateur.id}/sessions/")
    assert response.status_code == 403
