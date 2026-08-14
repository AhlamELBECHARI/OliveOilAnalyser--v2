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


# --- Prédictions multi-modèles (régression + classification) ---


@pytest.fixture
def modele_regression_reference(db):
    return Modele.objects.create(
        nom="Acidite-M5",
        version="1.0",
        algorithme="PLS",
        type_modele="regression",
        grandeur_predite="acidite",
        r2=0.95,
        rmsecv=0.1,
        est_reference=True,
    )


@pytest.fixture
def modele_classification(db):
    return Modele.objects.create(
        nom="Mixing1",
        version="1.0",
        algorithme="RandomForest",
        type_modele="classification",
        grandeur_predite="authenticite",
        exactitude=0.9,
    )


def _donnees_resultat_de_base(echantillon, modele):
    return {
        "echantillon": str(echantillon.id),
        "modele_utilise": modele.id,
        # Valeurs de secours : conservées telles quelles si aucun modèle de
        # référence n'a de prédiction correspondante dans `predictions`.
        "acidite": "9.999",
        "indice_peroxyde": "10.000",
        "conforme": False,
    }


def test_creer_resultat_avec_predictions_derive_acidite_depuis_reference(
    client_utilisateur, echantillon, modele_regression_reference, modele_classification
):
    donnees = _donnees_resultat_de_base(echantillon, modele_regression_reference)
    donnees["predictions"] = [
        {"modele": modele_regression_reference.id, "valeur_numerique": "0.450"},
        {
            "modele": modele_classification.id,
            "classe_predite": "pure",
            "score_confiance": 0.97,
        },
    ]

    response = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert response.status_code == 201
    resultat = Resultat.objects.get(pk=response.data["id"])
    # La valeur du modèle de référence (0.450) l'emporte sur celle envoyée
    # directement (9.999) dans le payload de secours.
    assert resultat.acidite == Decimal("0.450")
    assert resultat.modele_utilise_id == modele_regression_reference.id
    assert resultat.predictions.count() == 2


def test_creer_resultat_sans_predictions_garde_valeurs_directes(
    client_utilisateur, echantillon, modele
):
    """Sans bloc `predictions`, le comportement historique est inchangé :
    acidite/conforme restent ceux fournis directement."""
    donnees = _donnees_resultat_de_base(echantillon, modele)
    response = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert response.status_code == 201
    resultat = Resultat.objects.get(pk=response.data["id"])
    assert resultat.acidite == Decimal("9.999")


def test_creer_resultats_replicats_incremente_numero_replicat(
    client_utilisateur, echantillon, modele
):
    donnees = _donnees_resultat_de_base(echantillon, modele)
    premiere = client_utilisateur.post("/api/resultats/", donnees, format="json")
    seconde = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert premiere.data["numero_replicat"] == 1
    assert seconde.data["numero_replicat"] == 2


def test_prediction_regression_sans_valeur_numerique_rejetee(
    client_utilisateur, echantillon, modele_regression_reference
):
    donnees = _donnees_resultat_de_base(echantillon, modele_regression_reference)
    donnees["predictions"] = [{"modele": modele_regression_reference.id}]

    response = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert response.status_code == 400


def test_prediction_classification_sans_classe_rejetee(
    client_utilisateur, echantillon, modele_classification
):
    donnees = _donnees_resultat_de_base(echantillon, modele_classification)
    donnees["modele_utilise"] = modele_classification.id
    donnees["predictions"] = [{"modele": modele_classification.id, "score_confiance": 0.8}]

    response = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert response.status_code == 400


def test_predictions_meme_modele_deux_fois_rejete(
    client_utilisateur, echantillon, modele_regression_reference
):
    donnees = _donnees_resultat_de_base(echantillon, modele_regression_reference)
    donnees["predictions"] = [
        {"modele": modele_regression_reference.id, "valeur_numerique": "0.4"},
        {"modele": modele_regression_reference.id, "valeur_numerique": "0.5"},
    ]

    response = client_utilisateur.post("/api/resultats/", donnees, format="json")

    assert response.status_code == 400
