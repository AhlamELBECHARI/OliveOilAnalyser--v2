from decimal import Decimal

import pytest
from django.utils import timezone

from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat

pytestmark = pytest.mark.django_db


@pytest.fixture
def echantillon(utilisateur):
    return Echantillon.objects.create(
        numero="ECH-RESULTAT", date_analyse=timezone.now(), utilisateur=utilisateur
    )


@pytest.fixture
def modele(db):
    return Modele.objects.create(
        nom="PLS-Test", version="1.0", algorithme="PLS", r2=0.9, rmsecv=0.3
    )


def test_creer_resultat(client_utilisateur, echantillon, modele):
    response = client_utilisateur.post(
        "/api/resultats/",
        {
            "echantillon": str(echantillon.id),
            "modele_utilise": modele.id,
            "acidite": "0.500",
            "indice_peroxyde": "10.000",
            "conforme": True,
        },
        format="json",
    )
    assert response.status_code == 201


def test_creer_resultat_acidite_negative_rejetee(client_utilisateur, echantillon, modele):
    response = client_utilisateur.post(
        "/api/resultats/",
        {
            "echantillon": str(echantillon.id),
            "modele_utilise": modele.id,
            "acidite": "-1.000",
            "indice_peroxyde": "10.000",
            "conforme": False,
        },
        format="json",
    )
    assert response.status_code == 400


def test_lister_resultats_isole_par_utilisateur(client_utilisateur, echantillon, modele, autre_utilisateur):
    Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite=Decimal("0.5"),
        indice_peroxyde=Decimal("10"),
        conforme=True,
    )
    echantillon_autrui = Echantillon.objects.create(
        numero="ECH-AUTRUI-RES", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    Resultat.objects.create(
        echantillon=echantillon_autrui,
        modele_utilise=modele,
        acidite=Decimal("0.6"),
        indice_peroxyde=Decimal("12"),
        conforme=True,
    )

    response = client_utilisateur.get("/api/resultats/")
    assert response.data["count"] == 1


def test_non_authentifie_refuse(api_client):
    response = api_client.get("/api/resultats/")
    assert response.status_code == 401
