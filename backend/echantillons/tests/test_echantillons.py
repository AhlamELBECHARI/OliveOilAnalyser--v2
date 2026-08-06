import uuid
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


def test_creer_echantillon_avec_metadonnees_recolte(client_utilisateur):
    response = client_utilisateur.post(
        "/api/echantillons/",
        {
            "numero": "ECH-METADONNEES",
            "date_analyse": timezone.now().isoformat(),
            "producteur": "Domaine Alami",
            "region": "Marrakech-Safi",
            "date_recolte": "2026-07-12",
            "latitude": "31.6295",
            "longitude": "-7.9811",
        },
        format="json",
    )
    assert response.status_code == 201
    echantillon = Echantillon.objects.get(numero="ECH-METADONNEES")
    assert echantillon.producteur == "Domaine Alami"
    assert echantillon.region == "Marrakech-Safi"
    assert str(echantillon.date_recolte) == "2026-07-12"
    assert echantillon.latitude == Decimal("31.629500")


def test_latitude_hors_limites_rejetee(client_utilisateur):
    response = client_utilisateur.post(
        "/api/echantillons/",
        {
            "numero": "ECH-LAT-INVALIDE",
            "date_analyse": timezone.now().isoformat(),
            "latitude": "120.0",
        },
        format="json",
    )
    assert response.status_code == 400


def test_longitude_hors_limites_rejetee(client_utilisateur):
    response = client_utilisateur.post(
        "/api/echantillons/",
        {
            "numero": "ECH-LONG-INVALIDE",
            "date_analyse": timezone.now().isoformat(),
            "longitude": "200.0",
        },
        format="json",
    )
    assert response.status_code == 400


def test_creer_echantillon_avec_uuid_fourni_par_le_mobile(client_utilisateur):
    """La synchronisation hors ligne (Drift, côté frontend) génère l'UUID
    côté mobile avant même d'avoir du réseau : le serveur doit l'accepter
    tel quel plutôt que d'en générer un autre, sinon l'ID local et l'ID
    serveur divergent."""
    identifiant = uuid.uuid4()
    response = client_utilisateur.post(
        "/api/echantillons/",
        {
            "id": str(identifiant),
            "numero": "ECH-UUID-MOBILE",
            "date_analyse": timezone.now().isoformat(),
        },
        format="json",
    )
    assert response.status_code == 201
    assert response.data["id"] == str(identifiant)
    assert Echantillon.objects.filter(pk=identifiant).exists()


def test_rejouer_le_meme_uuid_apres_synchronisation_reussie_est_rejete(client_utilisateur):
    """Cas de retry réseau : le mobile renvoie la même requête (même UUID)
    parce qu'il n'a pas reçu la réponse de la première tentative, qui avait
    pourtant réussi. Le doublon de clé primaire doit remonter en 409 (voir
    core.exceptions), pas planter en 500 — le service de synchronisation
    interprète ce 409 comme "déjà synchronisé", pas comme un échec."""
    identifiant = uuid.uuid4()
    donnees = {
        "id": str(identifiant),
        "numero": "ECH-RETRY",
        "date_analyse": timezone.now().isoformat(),
    }
    premiere = client_utilisateur.post("/api/echantillons/", donnees, format="json")
    assert premiere.status_code == 201

    deuxieme = client_utilisateur.post("/api/echantillons/", donnees, format="json")
    assert deuxieme.status_code == 409


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
