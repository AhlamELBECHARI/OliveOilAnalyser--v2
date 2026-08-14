import pytest

from administration.models import JournalAudit
from administration.services import enregistrer_action

pytestmark = pytest.mark.django_db


def test_lister_journal_audit_admin_ok(client_administrateur, administrateur):
    enregistrer_action(
        action=JournalAudit.Action.CONNEXION_REUSSIE,
        acteur=administrateur,
        cible_type="Utilisateur",
        cible_id=administrateur.pk,
    )
    response = client_administrateur.get("/api/admin/journal-audit/")
    assert response.status_code == 200
    assert response.data["count"] >= 1


def test_lister_journal_audit_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/admin/journal-audit/")
    assert response.status_code == 403


def test_lister_journal_audit_filtre_par_action(client_administrateur, administrateur):
    enregistrer_action(action=JournalAudit.Action.CONNEXION_REUSSIE, acteur=administrateur)
    enregistrer_action(action=JournalAudit.Action.CONNEXION_ECHOUEE, acteur=administrateur)

    response = client_administrateur.get("/api/admin/journal-audit/?action=connexion_echouee")
    assert response.status_code == 200
    assert all(ligne["action"] == "connexion_echouee" for ligne in response.data["results"])


def test_login_reussi_journalise(api_client, utilisateur, mot_de_passe):
    api_client.post(
        "/api/auth/login/", {"email": utilisateur.email, "password": mot_de_passe}, format="json"
    )
    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.CONNEXION_REUSSIE, acteur=utilisateur
    ).exists()


def test_login_echoue_journalise(api_client, utilisateur):
    api_client.post(
        "/api/auth/login/", {"email": utilisateur.email, "password": "mauvais-mot-de-passe"}, format="json"
    )
    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.CONNEXION_ECHOUEE, acteur=utilisateur
    ).exists()
