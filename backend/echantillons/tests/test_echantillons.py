from decimal import Decimal

import pytest
from django.utils import timezone

from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat

pytestmark = pytest.mark.django_db


def test_creer_echantillon(client_utilisateur):
    response = client_utilisateur.post(
        "/api/echantillons/",
        {
            "numero": "ECH-001",
            "date_analyse": timezone.now().isoformat(),
            "origine": "Coopérative A",
        },
        format="json",
    )
    assert response.status_code == 201
    assert Echantillon.objects.count() == 1
    assert Echantillon.objects.get().utilisateur_id is not None


def test_lister_echantillons_isole_par_utilisateur(client_utilisateur, utilisateur, autre_utilisateur):
    Echantillon.objects.create(numero="ECH-A", date_analyse=timezone.now(), utilisateur=utilisateur)
    Echantillon.objects.create(numero="ECH-B", date_analyse=timezone.now(), utilisateur=autre_utilisateur)

    response = client_utilisateur.get("/api/echantillons/")
    assert response.status_code == 200
    numeros = [item["numero"] for item in response.data["results"]]
    assert numeros == ["ECH-A"]


def test_admin_voit_tous_les_echantillons(client_administrateur, utilisateur, autre_utilisateur):
    Echantillon.objects.create(numero="ECH-A", date_analyse=timezone.now(), utilisateur=utilisateur)
    Echantillon.objects.create(numero="ECH-B", date_analyse=timezone.now(), utilisateur=autre_utilisateur)

    response = client_administrateur.get("/api/echantillons/")
    assert response.data["count"] == 2


def test_numero_duplique_pour_meme_utilisateur_rejete(client_utilisateur, utilisateur):
    Echantillon.objects.create(numero="ECH-DUP", date_analyse=timezone.now(), utilisateur=utilisateur)
    response = client_utilisateur.post(
        "/api/echantillons/",
        {"numero": "ECH-DUP", "date_analyse": timezone.now().isoformat()},
        format="json",
    )
    assert response.status_code == 400


def test_meme_numero_pour_deux_utilisateurs_differents_autorise(client_utilisateur, autre_utilisateur):
    Echantillon.objects.create(
        numero="ECH-PARTAGE", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    response = client_utilisateur.post(
        "/api/echantillons/",
        {"numero": "ECH-PARTAGE", "date_analyse": timezone.now().isoformat()},
        format="json",
    )
    assert response.status_code == 201


def test_utilisateur_ne_peut_pas_acceder_a_echantillon_dautrui(client_utilisateur, autre_utilisateur):
    echantillon = Echantillon.objects.create(
        numero="ECH-PRIVE", date_analyse=timezone.now(), utilisateur=autre_utilisateur
    )
    response = client_utilisateur.get(f"/api/echantillons/{echantillon.id}/")
    assert response.status_code == 404


def test_non_authentifie_refuse(api_client):
    response = api_client.get("/api/echantillons/")
    assert response.status_code == 401


def test_suppression_bloquee_si_resultat_associe(client_utilisateur, utilisateur):
    echantillon = Echantillon.objects.create(
        numero="ECH-PROTEGE", date_analyse=timezone.now(), utilisateur=utilisateur
    )
    modele = Modele.objects.create(
        nom="PLS-v1", version="1.0", algorithme="PLS", r2=0.95, rmsecv=0.2
    )
    Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite=Decimal("0.500"),
        indice_peroxyde=Decimal("10.000"),
        conforme=True,
    )

    response = client_utilisateur.delete(f"/api/echantillons/{echantillon.id}/")
    assert response.status_code == 409
