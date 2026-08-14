import pytest
from django.utils import timezone

from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat

pytestmark = pytest.mark.django_db


def test_supervision_admin_ok(client_administrateur):
    response = client_administrateur.get("/api/admin/supervision/")
    assert response.status_code == 200
    assert "etat_systeme" in response.data
    assert "activite_jour" in response.data
    assert "alertes_non_resolues" in response.data
    assert "activite_par_operateur" in response.data
    assert "anomalies" in response.data


def test_supervision_non_admin_refuse(client_utilisateur):
    response = client_utilisateur.get("/api/admin/supervision/")
    assert response.status_code == 403


def test_supervision_non_authentifie_refuse(api_client):
    response = api_client.get("/api/admin/supervision/")
    assert response.status_code == 401


def test_supervision_activite_par_operateur_reflete_les_resultats(
    client_administrateur, utilisateur
):
    echantillon = Echantillon.objects.create(
        numero="ECH-SUPERVISION", date_analyse=timezone.now(), utilisateur=utilisateur
    )
    modele = Modele.objects.create(
        nom="PLS-Supervision", version="1.0", algorithme="PLS", r2=0.9, rmsecv=0.1
    )
    Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite="0.500",
        indice_peroxyde="10.000",
        conforme=True,
    )

    response = client_administrateur.get("/api/admin/supervision/")
    operateurs = {o["utilisateur_id"]: o for o in response.data["activite_par_operateur"]}
    assert operateurs[utilisateur.id]["nombre_analyses"] == 1
