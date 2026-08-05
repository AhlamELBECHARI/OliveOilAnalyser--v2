import pytest
from django.utils import timezone

from alertes.models import Alerte
from echantillons.models import Echantillon

pytestmark = pytest.mark.django_db


def _creer_alerte(echantillon=None, **kwargs):
    return Alerte.objects.create(
        echantillon=echantillon,
        type=Alerte.Type.SEUIL_DEPASSE,
        message="Test",
        niveau_gravite=Alerte.NiveauGravite.AVERTISSEMENT,
        **kwargs,
    )


def test_lister_alertes_isole_par_utilisateur(client_utilisateur, utilisateur, autre_utilisateur):
    ech_a = Echantillon.objects.create(
        numero="ECH-A", date_analyse=timezone.now(), utilisateur=utilisateur
    )
    ech_b = Echantillon.objects.create(
        numero="ECH-B", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    _creer_alerte(echantillon=ech_a)
    _creer_alerte(echantillon=ech_b)

    response = client_utilisateur.get("/api/alertes/")
    assert response.status_code == 200
    assert len(response.data["results"]) == 1


def test_admin_voit_toutes_les_alertes_y_compris_systeme(
    client_administrateur, utilisateur, autre_utilisateur
):
    ech_a = Echantillon.objects.create(
        numero="ECH-A", date_analyse=timezone.now(), utilisateur=utilisateur
    )
    _creer_alerte(echantillon=ech_a)
    _creer_alerte(echantillon=None)  # alerte système, sans échantillon

    response = client_administrateur.get("/api/alertes/")
    assert response.status_code == 200
    assert len(response.data["results"]) == 2


def test_alertes_non_authentifie_refuse(api_client):
    response = api_client.get("/api/alertes/")
    assert response.status_code == 401


def test_alertes_lecture_seule(client_utilisateur):
    alerte = _creer_alerte(echantillon=None)
    response = client_utilisateur.post(
        "/api/alertes/", {"message": "Nouvelle alerte"}, format="json"
    )
    assert response.status_code == 405


def test_alertes_filtre_par_est_resolue(client_administrateur):
    _creer_alerte(echantillon=None, est_resolue=False)
    _creer_alerte(echantillon=None, est_resolue=True)

    response = client_administrateur.get("/api/alertes/?est_resolue=false")
    assert response.status_code == 200
    assert response.data["count"] == 1
    assert response.data["results"][0]["est_resolue"] is False
