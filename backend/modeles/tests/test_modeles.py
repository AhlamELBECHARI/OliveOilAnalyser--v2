import hashlib

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile

from modeles.models import Modele

pytestmark = pytest.mark.django_db


def donnees_modele(suffixe="1"):
    return {
        "nom": f"PLS-{suffixe}",
        "version": "1.0",
        "algorithme": "PLS",
        "hyperparametres": {"n_components": 5},
        "r2": 0.95,
        "rmsecv": 0.2,
    }


def fichier_modele(nom="modele.pkl", contenu=b"contenu-binaire-factice-non-execute"):
    return SimpleUploadedFile(nom, contenu, content_type="application/octet-stream")


def donnees_modele_multipart(suffixe="1"):
    """Le multipart ne supporte pas les valeurs imbriquées : `hyperparametres`
    (JSONField) en est exclu, il reste optionnel côté serializer."""
    donnees = donnees_modele(suffixe)
    del donnees["hyperparametres"]
    return donnees


def test_lister_modeles_utilisateur_standard_autorise(client_utilisateur):
    response = client_utilisateur.get("/api/modeles/")
    assert response.status_code == 200


def test_lister_modeles_non_authentifie_refuse(api_client):
    response = api_client.get("/api/modeles/")
    assert response.status_code == 401


def test_creer_modele_admin_ok(client_administrateur):
    response = client_administrateur.post("/api/modeles/", donnees_modele("1"), format="json")
    assert response.status_code == 201


def test_creer_modele_utilisateur_standard_autorise(client_utilisateur):
    """Chantier 4 : l'import de modèle n'est plus réservé aux administrateurs
    (voir ModeleViewSet.get_permissions) — seules la modification et la
    suppression le restent (voir test_supprimer_modele_non_admin_refuse)."""
    response = client_utilisateur.post("/api/modeles/", donnees_modele("2"), format="json")
    assert response.status_code == 201


def test_creer_modele_rmsecv_negatif_rejete(client_administrateur):
    donnees = donnees_modele("3")
    donnees["rmsecv"] = -1
    response = client_administrateur.post("/api/modeles/", donnees, format="json")
    assert response.status_code == 400


def test_supprimer_modele_non_admin_refuse(client_utilisateur, client_administrateur):
    creation = client_administrateur.post("/api/modeles/", donnees_modele("4"), format="json")
    modele_id = creation.data["id"]
    response = client_utilisateur.delete(f"/api/modeles/{modele_id}/")
    assert response.status_code == 403


def test_modifier_modele_non_admin_refuse(client_utilisateur, client_administrateur):
    """Déprécier/réactiver un modèle affecte tous ses utilisateurs, pas
    seulement son auteur : reste réservé aux administrateurs même si
    l'import, lui, est désormais ouvert."""
    creation = client_administrateur.post("/api/modeles/", donnees_modele("5"), format="json")
    modele_id = creation.data["id"]
    response = client_utilisateur.patch(
        f"/api/modeles/{modele_id}/", {"est_deprecie": True}, format="json"
    )
    assert response.status_code == 403


# --- Import de fichier de modèle ---


def test_importer_modele_avec_fichier_admin_ok(client_administrateur):
    contenu = b"contenu-binaire-factice-non-execute"
    donnees = donnees_modele_multipart("fichier-ok")
    donnees["fichier"] = fichier_modele(contenu=contenu)

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 201
    modele = Modele.objects.get(pk=response.data["id"])
    assert modele.fichier.name.endswith(".pkl")
    assert modele.empreinte_sha256 == hashlib.sha256(contenu).hexdigest()


def test_importer_modele_fichier_utilisateur_standard_autorise(client_utilisateur):
    contenu = b"contenu-binaire-factice-non-execute"
    donnees = donnees_modele_multipart("fichier-standard")
    donnees["fichier"] = fichier_modele(contenu=contenu)

    response = client_utilisateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 201
    modele = Modele.objects.get(pk=response.data["id"])
    # Les protections restent intactes pour tout appelant, admin ou non : le
    # fichier n'est jamais désérialisé, seule son empreinte est calculée.
    assert modele.empreinte_sha256 == hashlib.sha256(contenu).hexdigest()


def test_importer_modele_extension_non_autorisee_rejetee(client_administrateur):
    donnees = donnees_modele_multipart("extension-invalide")
    donnees["fichier"] = fichier_modele(nom="modele.exe")

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 400


def test_importer_modele_fichier_trop_volumineux_rejete(client_administrateur, monkeypatch):
    monkeypatch.setattr(Modele, "TAILLE_MAX_OCTETS", 10)
    donnees = donnees_modele_multipart("trop-gros")
    donnees["fichier"] = fichier_modele(contenu=b"x" * 100)

    response = client_administrateur.post("/api/modeles/", donnees, format="multipart")

    assert response.status_code == 400


def test_creer_modele_sans_fichier_reste_possible(client_administrateur):
    """Le fichier reste optionnel : un modèle peut être déclaré (métadonnées
    seules) avant que le fichier entraîné ne soit disponible."""
    response = client_administrateur.post(
        "/api/modeles/", donnees_modele("sans-fichier"), format="json"
    )
    assert response.status_code == 201
    assert response.data["empreinte_sha256"] == ""


# --- Type de modèle (régression / classification) et modèle de référence ---


def donnees_modele_classification(suffixe="1"):
    return {
        "nom": f"Mixing-{suffixe}",
        "version": "1.0",
        "algorithme": "RandomForest",
        "type_modele": "classification",
        "grandeur_predite": "authenticite",
        "exactitude": 0.92,
        "precision_classification": 0.9,
        "rappel": 0.88,
    }


def test_creer_modele_classification_sans_r2_rmsecv_ok(client_administrateur):
    """Les métriques de régression (r2/rmsecv) sont optionnelles pour un
    modèle de classification, qui a ses propres métriques dédiées."""
    response = client_administrateur.post(
        "/api/modeles/", donnees_modele_classification("class-1"), format="json"
    )
    assert response.status_code == 201
    assert response.data["r2"] is None
    assert response.data["rmsecv"] is None
    assert response.data["exactitude"] == 0.92


def test_definir_modele_reference_desactive_ancien(client_administrateur):
    """Un seul modèle de référence actif par grandeur prédite : en marquer
    un nouveau désactive automatiquement l'ancien."""
    donnees_a = donnees_modele("ref-a")
    donnees_a["est_reference"] = True
    reponse_a = client_administrateur.post("/api/modeles/", donnees_a, format="json")
    assert reponse_a.status_code == 201
    assert reponse_a.data["est_reference"] is True

    donnees_b = donnees_modele("ref-b")
    donnees_b["est_reference"] = True
    reponse_b = client_administrateur.post("/api/modeles/", donnees_b, format="json")
    assert reponse_b.status_code == 201
    assert reponse_b.data["est_reference"] is True

    modele_a = Modele.objects.get(pk=reponse_a.data["id"])
    assert modele_a.est_reference is False


# --- Espace admin : journalisation et historique d'utilisation ---


def test_deprecier_modele_journalise(client_administrateur):
    from administration.models import JournalAudit

    creation = client_administrateur.post("/api/modeles/", donnees_modele("depr-1"), format="json")
    modele_id = creation.data["id"]

    client_administrateur.patch(f"/api/modeles/{modele_id}/", {"est_deprecie": True}, format="json")

    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.DEPRECIATION_MODELE, cible_id=str(modele_id)
    ).exists()


def test_reactiver_modele_journalise(client_administrateur):
    from administration.models import JournalAudit

    creation = client_administrateur.post(
        "/api/modeles/", {**donnees_modele("reactiv-1"), "est_deprecie": True}, format="json"
    )
    modele_id = creation.data["id"]

    client_administrateur.patch(f"/api/modeles/{modele_id}/", {"est_deprecie": False}, format="json")

    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.REACTIVATION_MODELE, cible_id=str(modele_id)
    ).exists()


def test_definir_reference_journalise(client_administrateur):
    from administration.models import JournalAudit

    creation = client_administrateur.post("/api/modeles/", donnees_modele("ref-journal"), format="json")
    modele_id = creation.data["id"]

    client_administrateur.patch(f"/api/modeles/{modele_id}/", {"est_reference": True}, format="json")

    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.DEFINITION_MODELE_REFERENCE, cible_id=str(modele_id)
    ).exists()


def test_supprimer_modele_journalise(client_administrateur):
    from administration.models import JournalAudit

    creation = client_administrateur.post("/api/modeles/", donnees_modele("suppr-journal"), format="json")
    modele_id = creation.data["id"]

    client_administrateur.delete(f"/api/modeles/{modele_id}/")

    assert JournalAudit.objects.filter(
        action=JournalAudit.Action.SUPPRESSION_MODELE, cible_id=str(modele_id)
    ).exists()


def test_historique_utilisation_admin_ok(client_administrateur):
    creation = client_administrateur.post("/api/modeles/", donnees_modele("usage-1"), format="json")
    modele_id = creation.data["id"]

    response = client_administrateur.get(f"/api/modeles/{modele_id}/historique-utilisation/")

    assert response.status_code == 200
    assert response.data["nombre_resultats"] == 0
    assert response.data["derniere_utilisation"] is None


def test_historique_utilisation_non_admin_refuse(client_utilisateur, client_administrateur):
    creation = client_administrateur.post("/api/modeles/", donnees_modele("usage-2"), format="json")
    modele_id = creation.data["id"]

    response = client_utilisateur.get(f"/api/modeles/{modele_id}/historique-utilisation/")

    assert response.status_code == 403
