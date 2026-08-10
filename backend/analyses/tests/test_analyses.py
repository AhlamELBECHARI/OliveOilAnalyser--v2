from decimal import Decimal

import pytest
from django.utils import timezone

from comptes.services import obtenir_configuration
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
    producteur="",
    variete="",
    region="",
    date_calcul=None,
):
    echantillon = Echantillon.objects.create(
        numero=numero,
        date_analyse=timezone.now(),
        utilisateur=utilisateur,
        producteur=producteur,
        variete=variete,
        region=region,
    )
    resultat = Resultat.objects.create(
        echantillon=echantillon,
        modele_utilise=modele,
        acidite=Decimal(str(acidite)),
        indice_peroxyde=Decimal("10.000"),
        conforme=True,
    )
    if date_calcul is not None:
        Resultat.objects.filter(pk=resultat.pk).update(date_calcul=date_calcul)
    return resultat


# --- /api/analyses/historique/ ---


def test_historique_non_authentifie_refuse(api_client):
    response = api_client.get("/api/analyses/historique/")
    assert response.status_code == 401


def test_historique_isole_par_utilisateur(client_utilisateur, utilisateur, autre_utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")
    _creer_resultat(utilisateur=autre_utilisateur, modele=modele, acidite="0.5", numero="ECH-B")

    response = client_utilisateur.get("/api/analyses/historique/")
    assert response.status_code == 200
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-A"


def test_historique_admin_voit_tout(client_administrateur, utilisateur, autre_utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")
    _creer_resultat(utilisateur=autre_utilisateur, modele=modele, acidite="0.5", numero="ECH-B")

    response = client_administrateur.get("/api/analyses/historique/")
    assert response.data["count"] == 2


def test_historique_inclut_la_categorie_qualite(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-EVOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="1.5", numero="ECH-VOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="3.0", numero="ECH-LAMPANTE")

    response = client_utilisateur.get("/api/analyses/historique/")
    categories = {item["numero_echantillon"]: item["categorie"] for item in response.data["results"]}
    assert categories == {"ECH-EVOO": "evoo", "ECH-VOO": "voo", "ECH-LAMPANTE": "lampante"}


def test_historique_recherche_plein_texte(client_utilisateur, utilisateur, modele):
    _creer_resultat(
        utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A",
        producteur="Domaine Alami", variete="Picholine", region="Marrakech-Safi",
    )
    _creer_resultat(
        utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-B",
        producteur="Coopérative Saada", variete="Arbequina", region="Fès-Meknès",
    )

    response = client_utilisateur.get("/api/analyses/historique/?recherche=Alami")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-A"

    response = client_utilisateur.get("/api/analyses/historique/?recherche=Arbequina")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-B"


def test_historique_filtre_qualite(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-EVOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="3.0", numero="ECH-LAMPANTE")

    response = client_utilisateur.get("/api/analyses/historique/?qualite=lampante")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-LAMPANTE"


def test_historique_filtre_variete_et_region(client_utilisateur, utilisateur, modele):
    _creer_resultat(
        utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A",
        variete="Picholine", region="Marrakech-Safi",
    )
    _creer_resultat(
        utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-B",
        variete="Arbequina", region="Fès-Meknès",
    )

    response = client_utilisateur.get("/api/analyses/historique/?variete=Picholine")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-A"

    response = client_utilisateur.get("/api/analyses/historique/?region=Fès-Meknès")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-B"


def test_historique_filtre_plage_de_dates(client_utilisateur, utilisateur, modele):
    aujourd_hui = timezone.now()
    _creer_resultat(
        utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-ANCIEN",
        date_calcul=aujourd_hui - timezone.timedelta(days=60),
    )
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-RECENT")

    date_debut = (aujourd_hui - timezone.timedelta(days=5)).date().isoformat()
    response = client_utilisateur.get(f"/api/analyses/historique/?date_debut={date_debut}")
    assert response.data["count"] == 1
    assert response.data["results"][0]["numero_echantillon"] == "ECH-RECENT"


def test_historique_tri_par_acidite(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="1.5", numero="ECH-HAUT")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.2", numero="ECH-BAS")

    response = client_utilisateur.get("/api/analyses/historique/?tri=acidite")
    numeros = [item["numero_echantillon"] for item in response.data["results"]]
    assert numeros == ["ECH-BAS", "ECH-HAUT"]


def test_historique_tri_invalide_retombe_sur_defaut(client_utilisateur, utilisateur, modele):
    """Un paramètre `tri` non reconnu ne doit jamais lever d'erreur : on
    retombe sur le tri par défaut (date_calcul décroissant)."""
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-A")

    response = client_utilisateur.get("/api/analyses/historique/?tri=injection; DROP TABLE")
    assert response.status_code == 200


# --- /api/analyses/statistiques-rapides/ ---


def test_statistiques_rapides_non_authentifie_refuse(api_client):
    response = api_client.get("/api/analyses/statistiques-rapides/")
    assert response.status_code == 401


def test_statistiques_rapides_apercu(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-EVOO")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="1.5", numero="ECH-VOO")

    response = client_utilisateur.get("/api/analyses/statistiques-rapides/")
    assert response.status_code == 200
    apercu = response.data["apercu"]
    assert apercu["total_analyses"] == 2
    repartition = {ligne["categorie"]: ligne["effectif"] for ligne in apercu["repartition_qualite"]}
    assert repartition == {"evoo": 1, "voo": 1, "lampante": 0}
    assert apercu["ce_mois"]["valeur"] == 2


def test_statistiques_rapides_respecte_configuration(client_utilisateur, utilisateur, modele):
    """Même exigence que pour le dashboard : la classification doit suivre
    Configuration, pas des seuils codés en dur — les deux écrans doivent
    rester cohérents entre eux."""
    configuration = obtenir_configuration()
    configuration.seuil_acidite_evoo = Decimal("0.300")
    configuration.seuil_acidite_voo = Decimal("2.000")
    configuration.save(update_fields=["seuil_acidite_evoo", "seuil_acidite_voo"])

    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.5", numero="ECH-BASCULE")

    response = client_utilisateur.get("/api/analyses/statistiques-rapides/")
    repartition = {
        ligne["categorie"]: ligne["effectif"]
        for ligne in response.data["apercu"]["repartition_qualite"]
    }
    assert repartition == {"evoo": 0, "voo": 1, "lampante": 0}


def test_statistiques_rapides_tendance_acidite(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.400", numero="ECH-A")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.600", numero="ECH-B")

    response = client_utilisateur.get("/api/analyses/statistiques-rapides/")
    tendance = response.data["tendance_acidite_moyenne"]
    assert tendance["valeur"] == 0.5
    assert len(tendance["serie"]) == 14


def test_statistiques_rapides_min_max_acidite(client_utilisateur, utilisateur, modele):
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="0.200", numero="ECH-MIN")
    _creer_resultat(utilisateur=utilisateur, modele=modele, acidite="1.800", numero="ECH-MAX")

    response = client_utilisateur.get("/api/analyses/statistiques-rapides/")
    assert float(response.data["meilleure_qualite"]["valeur"]) == 0.2
    assert float(response.data["plus_forte_acidite"]["valeur"]) == 1.8


def test_statistiques_rapides_vide_ne_plante_pas(client_utilisateur):
    response = client_utilisateur.get("/api/analyses/statistiques-rapides/")
    assert response.status_code == 200
    assert response.data["apercu"]["total_analyses"] == 0
    assert response.data["tendance_acidite_moyenne"]["valeur"] is None
    assert response.data["analyses_par_jour"]["valeur"] == 0.0


# Les tests de POST /api/analyses/export/ et GET /api/rapports/<id>/telecharger/
# vivent dans analyses/tests/test_export.py (génération réelle du fichier).


def test_export_format_invalide_rejete(client_utilisateur):
    response = client_utilisateur.post(
        "/api/analyses/export/", {"contenu": "resultats", "format": "DOCX"}, format="json"
    )
    assert response.status_code == 400
