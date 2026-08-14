import pytest
from django.utils import timezone

from administration.models import JournalAudit
from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat

pytestmark = pytest.mark.django_db


def test_statistiques_occupation_admin_ok(client_administrateur):
    response = client_administrateur.get("/api/admin/donnees/statistiques/")
    assert response.status_code == 200
    assert "echantillons" in response.data
    assert "taille_base_octets" in response.data


def test_statistiques_occupation_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/admin/donnees/statistiques/")
    assert response.status_code == 403


@pytest.fixture
def echantillon_ancien(utilisateur):
    return Echantillon.objects.create(
        numero="ECH-ANCIEN",
        date_analyse=timezone.now() - timezone.timedelta(days=400),
        utilisateur=utilisateur,
    )


def test_purge_apercu_admin_ok(client_administrateur, echantillon_ancien):
    date_limite = timezone.now().date().isoformat()
    response = client_administrateur.post(
        "/api/admin/donnees/purge/apercu/", {"date_limite": date_limite}, format="json"
    )
    assert response.status_code == 200
    assert response.data["echantillons_a_supprimer"] == 1


def test_purge_apercu_ne_supprime_rien(client_administrateur, echantillon_ancien):
    date_limite = timezone.now().date().isoformat()
    client_administrateur.post(
        "/api/admin/donnees/purge/apercu/", {"date_limite": date_limite}, format="json"
    )
    assert Echantillon.objects.filter(pk=echantillon_ancien.pk).exists()


def test_purge_apercu_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.post(
        "/api/admin/donnees/purge/apercu/",
        {"date_limite": timezone.now().date().isoformat()},
        format="json",
    )
    assert response.status_code == 403


def test_purge_executer_admin_ok(client_administrateur, echantillon_ancien):
    modele = Modele.objects.create(
        nom="PLS-Purge", version="1.0", algorithme="PLS", r2=0.9, rmsecv=0.1
    )
    Resultat.objects.create(
        echantillon=echantillon_ancien,
        modele_utilise=modele,
        acidite="0.500",
        indice_peroxyde="10.000",
        conforme=True,
    )
    date_limite = timezone.now().date().isoformat()

    response = client_administrateur.post(
        "/api/admin/donnees/purge/", {"date_limite": date_limite}, format="json"
    )

    assert response.status_code == 200
    assert response.data["echantillons_supprimes"] == 1
    assert response.data["resultats_supprimes"] == 1
    assert not Echantillon.objects.filter(pk=echantillon_ancien.pk).exists()
    assert JournalAudit.objects.filter(action=JournalAudit.Action.PURGE_DONNEES).exists()


def test_purge_executer_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.post(
        "/api/admin/donnees/purge/",
        {"date_limite": timezone.now().date().isoformat()},
        format="json",
    )
    assert response.status_code == 403


def test_purge_ne_touche_pas_les_echantillons_recents(client_administrateur, utilisateur):
    recent = Echantillon.objects.create(
        numero="ECH-RECENT", date_analyse=timezone.now(), utilisateur=utilisateur
    )
    date_limite = (timezone.now() - timezone.timedelta(days=365)).date().isoformat()

    client_administrateur.post("/api/admin/donnees/purge/", {"date_limite": date_limite}, format="json")

    assert Echantillon.objects.filter(pk=recent.pk).exists()
