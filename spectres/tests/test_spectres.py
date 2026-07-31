import pytest
from django.utils import timezone

from echantillons.models import Echantillon
from spectres.models import Spectre

pytestmark = pytest.mark.django_db


@pytest.fixture
def echantillon(utilisateur):
    return Echantillon.objects.create(
        numero="ECH-SPECTRE", date_analyse=timezone.now(), utilisateur=utilisateur
    )


def test_creer_spectre_longueurs_coherentes(client_utilisateur, echantillon):
    response = client_utilisateur.post(
        "/api/spectres/",
        {
            "echantillon": str(echantillon.id),
            "valeurs_x": [1000, 1001, 1002],
            "valeurs_y": [0.1, 0.2, 0.3],
            "nombre_series": 3,
            "date_acquisition": timezone.now().isoformat(),
        },
        format="json",
    )
    assert response.status_code == 201
    assert Spectre.objects.count() == 1


def test_creer_spectre_longueurs_incoherentes_rejete(client_utilisateur, echantillon):
    response = client_utilisateur.post(
        "/api/spectres/",
        {
            "echantillon": str(echantillon.id),
            "valeurs_x": [1000, 1001, 1002],
            "valeurs_y": [0.1, 0.2],
            "nombre_series": 3,
            "date_acquisition": timezone.now().isoformat(),
        },
        format="json",
    )
    assert response.status_code == 400


def test_creer_spectre_sur_echantillon_dautrui_refuse(client_utilisateur, autre_utilisateur):
    echantillon_autrui = Echantillon.objects.create(
        numero="ECH-AUTRUI", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    response = client_utilisateur.post(
        "/api/spectres/",
        {
            "echantillon": str(echantillon_autrui.id),
            "valeurs_x": [1, 2],
            "valeurs_y": [1, 2],
            "nombre_series": 2,
            "date_acquisition": timezone.now().isoformat(),
        },
        format="json",
    )
    assert response.status_code == 403


def test_lister_spectres_isole_par_utilisateur(client_utilisateur, echantillon, autre_utilisateur):
    echantillon_autrui = Echantillon.objects.create(
        numero="ECH-AUTRUI-2", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    Spectre.objects.create(
        echantillon=echantillon,
        valeurs_x=[1, 2],
        valeurs_y=[1, 2],
        nombre_series=2,
        date_acquisition=timezone.now(),
    )
    Spectre.objects.create(
        echantillon=echantillon_autrui,
        valeurs_x=[1, 2],
        valeurs_y=[1, 2],
        nombre_series=2,
        date_acquisition=timezone.now(),
    )

    response = client_utilisateur.get("/api/spectres/")
    assert response.data["count"] == 1


def test_non_authentifie_refuse(api_client):
    response = api_client.get("/api/spectres/")
    assert response.status_code == 401
