import pytest
from rest_framework.test import APIClient

from comptes.models import Utilisateur

MOT_DE_PASSE_TEST = "MotDePasse123!"


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture(autouse=True)
def _media_root_temporaire(settings, tmp_path):
    """Isole les fichiers écrits pendant les tests (exports, modèles
    importés) dans un répertoire temporaire — jamais backend/media/."""
    settings.MEDIA_ROOT = tmp_path


@pytest.fixture
def mot_de_passe():
    return MOT_DE_PASSE_TEST


@pytest.fixture
def utilisateur(db, mot_de_passe):
    return Utilisateur.objects.create_user(
        email="utilisateur@example.com", nom="Utilisateur Test", password=mot_de_passe
    )


@pytest.fixture
def autre_utilisateur(db, mot_de_passe):
    return Utilisateur.objects.create_user(
        email="autre@example.com", nom="Autre Utilisateur", password=mot_de_passe
    )


@pytest.fixture
def administrateur(db, mot_de_passe):
    return Utilisateur.objects.create_user(
        email="admin@example.com",
        nom="Admin Test",
        password=mot_de_passe,
        role=Utilisateur.Role.ADMINISTRATEUR,
        is_staff=True,
    )


@pytest.fixture
def client_utilisateur(utilisateur):
    client = APIClient()
    client.force_authenticate(user=utilisateur)
    return client


@pytest.fixture
def client_administrateur(administrateur):
    client = APIClient()
    client.force_authenticate(user=administrateur)
    return client
