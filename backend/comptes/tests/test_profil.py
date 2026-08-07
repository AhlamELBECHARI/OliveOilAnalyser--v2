import pytest

pytestmark = pytest.mark.django_db


def test_obtenir_mon_profil(client_utilisateur, utilisateur):
    response = client_utilisateur.get("/api/utilisateurs/moi/")
    assert response.status_code == 200
    assert response.data["email"] == utilisateur.email
    assert response.data["nom"] == utilisateur.nom


def test_obtenir_mon_profil_non_authentifie_refuse(api_client):
    response = api_client.get("/api/utilisateurs/moi/")
    assert response.status_code == 401


def test_modifier_mon_profil(client_utilisateur, utilisateur):
    response = client_utilisateur.patch(
        "/api/utilisateurs/moi/",
        {
            "nom": "Nouveau Nom",
            "telephone": "+212 6 12 34 56 78",
            "fonction": "Chercheur Principal",
            "laboratoire": "Laboratoire Qualité",
            "institution": "UM6P",
        },
        format="json",
    )
    assert response.status_code == 200
    assert response.data["nom"] == "Nouveau Nom"
    assert response.data["telephone"] == "+212 6 12 34 56 78"
    assert response.data["fonction"] == "Chercheur Principal"

    utilisateur.refresh_from_db()
    assert utilisateur.nom == "Nouveau Nom"
    assert utilisateur.laboratoire == "Laboratoire Qualité"
    assert utilisateur.institution == "UM6P"


def test_modifier_mon_profil_ignore_email_envoye_par_le_client(client_utilisateur, utilisateur):
    ancien_email = utilisateur.email
    response = client_utilisateur.patch(
        "/api/utilisateurs/moi/", {"email": "autre-adresse@example.com"}, format="json"
    )
    assert response.status_code == 200
    utilisateur.refresh_from_db()
    assert utilisateur.email == ancien_email


def test_modifier_mon_profil_ne_peut_pas_elever_son_propre_role(client_utilisateur, utilisateur):
    response = client_utilisateur.patch(
        "/api/utilisateurs/moi/",
        {"role": "administrateur", "is_staff": True, "is_superuser": True},
        format="json",
    )
    assert response.status_code == 200
    utilisateur.refresh_from_db()
    assert utilisateur.role == "utilisateur"
    assert utilisateur.is_staff is False
    assert utilisateur.is_superuser is False


def test_modifier_le_profil_dautrui_impossible(client_utilisateur, autre_utilisateur):
    """PATCH /api/utilisateurs/moi/ n'accepte aucun identifiant de
    ressource : il n'y a physiquement aucun moyen de cibler le profil d'un
    autre utilisateur par cet endpoint, quel que soit le contenu envoyé."""
    response = client_utilisateur.patch(
        "/api/utilisateurs/moi/", {"nom": "Usurpation"}, format="json"
    )
    assert response.status_code == 200

    autre_utilisateur.refresh_from_db()
    assert autre_utilisateur.nom != "Usurpation"
