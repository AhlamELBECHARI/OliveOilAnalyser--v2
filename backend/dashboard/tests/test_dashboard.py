from decimal import Decimal

import pytest
from django.utils import timezone

from comptes.services import obtenir_configuration
from dashboard.services import _bornes_mois
from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat

pytestmark = pytest.mark.django_db


@pytest.fixture
def modele(db):
    return Modele.objects.create(
        nom="NIR-Acidite", version="1.0", algorithme="PLS", r2=0.95, rmsecv=0.05
    )


def _creer_resultat(
    *,
    utilisateur,
    modele,
    acidite,
    numero,
    origine="",
    variete="",
    date_calcul=None,
    duree_analyse_secondes=None,
):
    echantillon = Echantillon.objects.create(
        numero=numero,
        date_analyse=timezone.now(),
        utilisateur=utilisateur,
        origine=origine,
        variete=variete,
    )
    resultat = Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite=Decimal(str(acidite)),
        indice_peroxyde=Decimal("10.000"),
        duree_analyse_secondes=duree_analyse_secondes,
        conforme=True,
    )
    if date_calcul is not None:
        Resultat.objects.filter(pk=resultat.pk).update(date_calcul=date_calcul)
    return resultat


def test_dashboard_non_authentifie_refuse(api_client):
    response = api_client.get("/api/dashboard/statistiques/")
    assert response.status_code == 401


def test_dashboard_isole_par_utilisateur(
    client_utilisateur, utilisateur, autre_utilisateur, modele
):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")
    _creer_resultat(utilisateur=autre_utilisateur, modele=modele, acidite="0.5", numero="ECH-B")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert response.data["analyses_ce_mois"]["valeur"] == 1
    assert response.data["echantillons_totaux"]["valeur"] == 1
    assert len(response.data["analyses_recentes"]) == 1
    assert response.data["analyses_recentes"][0]["numero"] == "ECH-A"


def test_dashboard_admin_voit_tout(client_administrateur, utilisateur, autre_utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")
    _creer_resultat(utilisateur=autre_utilisateur, modele=modele, acidite="0.5", numero="ECH-B")

    response = client_administrateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert response.data["analyses_ce_mois"]["valeur"] == 2
    assert response.data["echantillons_totaux"]["valeur"] == 2


def test_dashboard_repartition_qualite_par_categorie(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-EVOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="1.5", numero="ECH-VOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="3.0", numero="ECH-LAMPANTE")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    repartition = {ligne["categorie"]: ligne["effectif"] for ligne in response.data["repartition_qualite"]}
    assert repartition == {"evoo": 1, "voo": 1, "lampante": 1}

    categories_analyses_recentes = {
        item["numero"]: item["categorie"] for item in response.data["analyses_recentes"]
    }
    assert categories_analyses_recentes["ECH-EVOO"] == "evoo"
    assert categories_analyses_recentes["ECH-VOO"] == "voo"
    assert categories_analyses_recentes["ECH-LAMPANTE"] == "lampante"


def test_dashboard_serie_7_jours_toujours_7_points(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert len(response.data["serie_7_jours"]) == 7
    assert sum(point["nombre_analyses"] for point in response.data["serie_7_jours"]) == 1


def test_dashboard_repartition_qualite_respecte_configuration(
    client_utilisateur, utilisateur, modele
):
    """La classification EVOO/VOO/Lampante doit suivre les seuils stockés
    dans Configuration, pas des constantes codées en dur : abaisser le
    seuil EVOO à 0.3 doit faire basculer un résultat à 0.5 vers VOO."""
    configuration = obtenir_configuration()
    configuration.seuil_acidite_evoo = Decimal("0.300")
    configuration.seuil_acidite_voo = Decimal("2.000")
    configuration.save(update_fields=["seuil_acidite_evoo", "seuil_acidite_voo"])

    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-BASCULE")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    repartition = {
        ligne["categorie"]: ligne["effectif"] for ligne in response.data["repartition_qualite"]
    }
    assert repartition == {"evoo": 0, "voo": 1, "lampante": 0}
    assert response.data["analyses_recentes"][0]["categorie"] == "voo"


def test_dashboard_temps_moyen_utilise_la_duree_reelle_enregistree(
    client_utilisateur, utilisateur, modele
):
    _creer_resultat(
        utilisateur=utilisateur,
        modele=modele,
        acidite="0.5",
        numero="ECH-RAPIDE",
        duree_analyse_secondes=60,
    )
    _creer_resultat(
        utilisateur=utilisateur,
        modele=modele,
        acidite="0.5",
        numero="ECH-LENT",
        duree_analyse_secondes=180,
    )
    # Résultat sans durée enregistrée : ne doit pas fausser la moyenne vers 0.
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-SANS-DUREE")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert response.data["temps_moyen_par_analyse_minutes"]["valeur"] == 2.0


def test_dashboard_analyses_recentes_incluent_resultat_id(client_utilisateur, utilisateur, modele):
    resultat = _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-ID")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert response.data["analyses_recentes"][0]["resultat_id"] == str(resultat.id)


def test_dashboard_variation_vs_mois_precedent(client_utilisateur, utilisateur, modele):
    debut_mois_precedent, _ = _bornes_mois(timezone.now())
    _creer_resultat(
        utilisateur=utilisateur,
        modele=modele,
        acidite="0.5",
        numero="ECH-ANCIEN",
        date_calcul=debut_mois_precedent + timezone.timedelta(days=2),
    )
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-NOUVEAU")

    response = client_utilisateur.get("/api/dashboard/statistiques/")
    assert response.status_code == 200
    assert response.data["analyses_ce_mois"]["valeur"] == 1
    # Comparé à 1 analyse le mois précédent : 0 % de variation.
    assert response.data["analyses_ce_mois"]["variation_pourcentage"] == 0.0
