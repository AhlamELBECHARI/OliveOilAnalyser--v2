"""Toute la logique métier (et les requêtes ORM) pour l'espace admin :
journal d'audit, supervision, gestion des données.
"""

from datetime import timedelta

from django.db import connection
from django.db.models import Case, Count, IntegerField, Max, When
from django.utils import timezone
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken

from alertes.models import Alerte
from comptes.models import Utilisateur
from comptes.services import obtenir_configuration
from core.qualite import annotation_categorie
from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat
from spectres.models import Spectre

from .models import JournalAudit


def enregistrer_action(*, action, acteur=None, cible_type="", cible_id="", details=None):
    """Point d'entrée UNIQUE d'écriture du journal d'audit — appelé
    exclusivement depuis la couche services des apps concernées (comptes,
    modeles...), jamais depuis une vue. Ne lève jamais d'exception : une
    panne d'écriture du journal ne doit jamais faire échouer l'action
    métier qu'il trace."""
    try:
        JournalAudit.objects.create(
            action=action,
            acteur=acteur,
            cible_type=cible_type,
            cible_id=str(cible_id) if cible_id else "",
            details=details or {},
        )
    except Exception:  # noqa: BLE001 — voir docstring : ne jamais propager.
        pass


def lister_journal_audit(*, action=None, acteur_id=None):
    queryset = JournalAudit.objects.select_related("acteur").all()
    if action:
        queryset = queryset.filter(action=action)
    if acteur_id:
        queryset = queryset.filter(acteur_id=acteur_id)
    return queryset


def _variation_pourcentage(valeur_actuelle, valeur_precedente):
    if valeur_actuelle is None or not valeur_precedente:
        return None
    return round((valeur_actuelle - valeur_precedente) / valeur_precedente * 100, 1)


def _taille_base_octets():
    """Spécifique Postgres (voir config.settings.DATABASES) : taille totale
    de la base sur disque, tous objets confondus (tables, index...)."""
    with connection.cursor() as curseur:
        curseur.execute("SELECT pg_database_size(current_database())")
        return curseur.fetchone()[0]


def _etat_systeme():
    return {
        # Cette fonction ne s'exécute que si l'API répond déjà : la valeur
        # est donc toujours vraie par construction, jamais mesurée.
        "api_disponible": True,
        "base_de_donnees_disponible": True,
        "taille_base_octets": _taille_base_octets(),
        # Aucun système de sauvegarde automatisé n'est en place à ce stade
        # (voir README) : jamais de date inventée, plutôt `null` explicite
        # que l'écran affiche comme "aucune sauvegarde enregistrée".
        "date_derniere_sauvegarde": None,
        # L'API ne reçoit aucune télémétrie des analyseurs : la connexion
        # Bluetooth est un flux purement local au téléphone (voir
        # features/analyseur côté Flutter), jamais rapportée au serveur.
        "nombre_analyseurs_recents": None,
    }


def _activite_jour():
    maintenant = timezone.now()
    aujourd_hui = maintenant.date()
    hier = aujourd_hui - timedelta(days=1)
    debut_semaine = aujourd_hui - timedelta(days=aujourd_hui.weekday())

    analyses_aujourd_hui = Resultat.objects.filter(date_calcul__date=aujourd_hui).count()
    analyses_hier = Resultat.objects.filter(date_calcul__date=hier).count()

    return {
        "utilisateurs_connectes": Utilisateur.objects.filter(last_login__date=aujourd_hui).count(),
        "sessions_actives": OutstandingToken.objects.filter(expires_at__gt=maintenant)
        .exclude(blacklistedtoken__isnull=False)
        .count(),
        "analyses_aujourd_hui": analyses_aujourd_hui,
        "analyses_cette_semaine": Resultat.objects.filter(date_calcul__date__gte=debut_semaine).count(),
        "variation_pourcentage": _variation_pourcentage(analyses_aujourd_hui, analyses_hier),
    }


def _alertes_non_resolues():
    ordre_gravite = Case(
        When(niveau_gravite=Alerte.NiveauGravite.CRITIQUE, then=0),
        When(niveau_gravite=Alerte.NiveauGravite.AVERTISSEMENT, then=1),
        default=2,
        output_field=IntegerField(),
    )
    return list(
        Alerte.objects.filter(est_resolue=False)
        .select_related("echantillon")
        .annotate(_ordre_gravite=ordre_gravite)
        .order_by("_ordre_gravite", "-date_creation")[:20]
    )


def _activite_par_operateur():
    configuration = obtenir_configuration()
    operateurs = []
    for utilisateur in Utilisateur.objects.filter(role=Utilisateur.Role.UTILISATEUR):
        resultats_operateur = Resultat.objects.filter(echantillon__utilisateur=utilisateur)
        total = resultats_operateur.count()
        if total == 0:
            continue
        repartition = (
            resultats_operateur.annotate(
                categorie=annotation_categorie(
                    seuil_evoo=configuration.seuil_acidite_evoo,
                    seuil_voo=configuration.seuil_acidite_voo,
                )
            )
            .values("categorie")
            .annotate(effectif=Count("id"))
        )
        operateurs.append(
            {
                "utilisateur_id": utilisateur.id,
                "nom": utilisateur.nom,
                "email": utilisateur.email,
                "nombre_analyses": total,
                "repartition_qualite": {ligne["categorie"]: ligne["effectif"] for ligne in repartition},
                "derniere_activite": resultats_operateur.aggregate(d=Max("date_calcul"))["d"],
            }
        )
    operateurs.sort(key=lambda o: o["nombre_analyses"], reverse=True)
    return operateurs


def _anomalies():
    maintenant = timezone.now()
    modeles_deprecies_references = (
        Modele.objects.filter(
            est_deprecie=True,
            predictions__resultat__date_calcul__gte=maintenant - timedelta(days=30),
        )
        .distinct()
        .count()
    )
    return {
        "comptes_verrouilles": Utilisateur.objects.filter(verrouille_jusqu_a__gt=maintenant).count(),
        # Concepts purement côté mobile (statut de synchronisation Drift
        # local) : jamais remontés au serveur, donc pas mesurables ici.
        "echecs_synchronisation": None,
        # Aucun état "erreur" n'existe sur Resultat : un résultat existe ou
        # n'existe pas, il n'y a pas d'état intermédiaire en échec côté API.
        "resultats_en_erreur": None,
        "modeles_deprecies_references": modeles_deprecies_references,
    }


def obtenir_supervision():
    """Une seule requête HTTP (GET /api/admin/supervision/) pour tout
    l'écran Supervision — toutes les agrégations sont calculées en base,
    jamais chargées en mémoire pour être recalculées côté Python."""
    return {
        "etat_systeme": _etat_systeme(),
        "activite_jour": _activite_jour(),
        "alertes_non_resolues": _alertes_non_resolues(),
        "activite_par_operateur": _activite_par_operateur(),
        "anomalies": _anomalies(),
    }


# --- Gestion des données ---


def statistiques_occupation():
    """Nombre de lignes par table principale — sert l'écran "Gestion des
    données" (Partie Administration)."""
    return {
        "echantillons": Echantillon.objects.count(),
        "spectres": Spectre.objects.count(),
        "resultats": Resultat.objects.count(),
        "modeles": Modele.objects.count(),
        "utilisateurs": Utilisateur.objects.count(),
        "taille_base_octets": _taille_base_octets(),
    }


def previsualiser_purge(*, date_limite):
    """Récapitulatif de ce qui SERAIT supprimé, sans rien supprimer — sert le
    garde-fou "confirmation explicite avec récapitulatif" de l'écran Gestion
    des données. Mêmes requêtes de comptage que purger_donnees_avant."""
    echantillons_cibles = Echantillon.objects.filter(date_analyse__date__lt=date_limite)
    return {
        "echantillons_a_supprimer": echantillons_cibles.count(),
        "spectres_a_supprimer": Spectre.objects.filter(echantillon__in=echantillons_cibles).count(),
        "resultats_a_supprimer": Resultat.objects.filter(echantillon__in=echantillons_cibles).count(),
    }


def purger_donnees_avant(*, date_limite, utilisateur):
    """Supprime les échantillons antérieurs à `date_limite`, et
    explicitement leurs résultats/spectres d'abord (tous deux en PROTECT sur
    echantillon — jamais de suppression en cascade implicite sur des données
    scientifiques)."""
    echantillons_cibles = Echantillon.objects.filter(date_analyse__date__lt=date_limite)

    resultats_supprimes, _ = Resultat.objects.filter(echantillon__in=echantillons_cibles).delete()
    spectres_supprimes, _ = Spectre.objects.filter(echantillon__in=echantillons_cibles).delete()
    echantillons_supprimes, _ = echantillons_cibles.delete()

    enregistrer_action(
        action=JournalAudit.Action.PURGE_DONNEES,
        acteur=utilisateur,
        details={
            "date_limite": date_limite.isoformat(),
            "echantillons_supprimes": echantillons_supprimes,
            "spectres_supprimes": spectres_supprimes,
            "resultats_supprimes": resultats_supprimes,
        },
    )
    return {
        "echantillons_supprimes": echantillons_supprimes,
        "spectres_supprimes": spectres_supprimes,
        "resultats_supprimes": resultats_supprimes,
    }
