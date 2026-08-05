"""
Commande de gestion pour peupler la base avec des données de démonstration
réalistes (échantillons, spectres, résultats), utile pour visualiser le
tableau de bord avant que les vraies analyses n'existent.

Toutes les données générées sont taguées par une convention de nommage
(numéro d'échantillon préfixé "DEMO-", modèle nommé "NIR-Demo") plutôt que
par un champ dédié dans les modèles : aucune logique de démonstration n'est
introduite dans models.py/services.py/serializers.py, uniquement dans cette
commande, qui peut être supprimée sans laisser de trace structurelle.

Usage :
    python manage.py seed_demo                  # seed pour tous les utilisateurs
    python manage.py seed_demo --email a@b.com   # seed pour un seul utilisateur
    python manage.py seed_demo --nombre 50       # nombre d'échantillons par utilisateur
    python manage.py seed_demo --clear           # supprime uniquement les données taguées "démo"
"""

import hashlib
import json
import random
from datetime import timedelta
from decimal import Decimal

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from comptes.models import Utilisateur
from comptes.services import SEUIL_ACIDITE_DEFAUT, SEUIL_PEROXYDE_DEFAUT
from echantillons.models import Echantillon
from modeles.models import Modele
from resultats.models import Resultat
from spectres.models import Spectre

PREFIXE_DEMO = "DEMO-"
MODELE_DEMO_NOM = "NIR-Demo"

# Compte à identifiants fixes utilisé par le bouton "Mode démo" du frontend :
# celui-ci effectue une vraie connexion (POST /api/auth/login/) avec ces
# identifiants plutôt que de contourner l'authentification — le mode démo
# ne sert qu'à éviter de les saisir manuellement, pas à simuler des données
# côté Flutter (voir core/demo/ dans le frontend).
DEMO_EMAIL = "demo@oliveiq.local"
DEMO_PASSWORD = "OliveIQDemo123!"
DEMO_NOM = "Laboratoire Démo"

ORIGINES = [
    "Domaine El Baraka",
    "Coopérative Ait Yazza",
    "Ferme Zeitoun",
    "Domaine Al Wahda",
    "Coopérative Sud Atlas",
    "Domaine Oulad Said",
]

VARIETES = ["Picholine", "Arbequina", "Koroneiki", "Picual", "Haouzia", "Menara"]

# Pondération choisie pour un jeu de démo réaliste : majorité d'huiles extra
# vierges, une part de vierges, une petite part de lampantes.
BANDES_ACIDITE = [
    ("evoo", 0.70, (0.10, 0.80)),
    ("voo", 0.22, (0.81, 2.00)),
    ("lampante", 0.08, (2.01, 4.50)),
]


class Command(BaseCommand):
    help = "Peuple (ou vide) la base avec des échantillons/spectres/résultats de démonstration."

    def add_arguments(self, parser):
        parser.add_argument(
            "--email",
            type=str,
            default=None,
            help="Ne seed que pour cet utilisateur (doit déjà exister). Par défaut : tous.",
        )
        parser.add_argument(
            "--nombre",
            type=int,
            default=30,
            help="Nombre d'échantillons de démonstration à générer par utilisateur (défaut 30).",
        )
        parser.add_argument(
            "--clear",
            action="store_true",
            help="Supprime uniquement les données taguées démo, sans en générer de nouvelles.",
        )

    def handle(self, *args, **options):
        if options["clear"]:
            self._vider()
            return

        # Créé avant la résolution des utilisateurs cibles : avec role=utilisateur
        # par défaut, le compte démo est automatiquement inclus dans le mode
        # "tous les utilisateurs" (options["email"] non fourni) sans traitement
        # spécial.
        self._obtenir_ou_creer_utilisateur_demo()

        utilisateurs = self._obtenir_utilisateurs_cibles(options["email"])
        if not utilisateurs:
            raise CommandError(
                "Aucun utilisateur trouvé. Créez d'abord un compte via /api/auth/register/."
            )

        modele = self._obtenir_ou_creer_modele_demo()

        for utilisateur in utilisateurs:
            self._seed_pour_utilisateur(utilisateur, modele, options["nombre"])

        self.stdout.write(
            self.style.SUCCESS(
                f"Données de démonstration générées pour {len(utilisateurs)} utilisateur(s)."
            )
        )
        self.stdout.write(f"Compte démo (bouton « Mode démo ») : {DEMO_EMAIL} / {DEMO_PASSWORD}")

    def _obtenir_ou_creer_utilisateur_demo(self):
        try:
            return Utilisateur.objects.get(email=DEMO_EMAIL)
        except Utilisateur.DoesNotExist:
            utilisateur = Utilisateur.objects.create_user(
                email=DEMO_EMAIL, nom=DEMO_NOM, password=DEMO_PASSWORD
            )
            self.stdout.write(f"Compte démo créé : {DEMO_EMAIL}")
            return utilisateur

    def _obtenir_utilisateurs_cibles(self, email):
        if email:
            try:
                return [Utilisateur.objects.get(email=email.strip().lower())]
            except Utilisateur.DoesNotExist as exc:
                raise CommandError(f"Aucun utilisateur avec l'email {email!r}.") from exc
        return list(Utilisateur.objects.filter(role=Utilisateur.Role.UTILISATEUR))

    def _obtenir_ou_creer_modele_demo(self):
        modele, cree = Modele.objects.get_or_create(
            nom=MODELE_DEMO_NOM,
            version="1.0",
            defaults={
                "algorithme": "PLS-NIR",
                "hyperparametres": {"n_composantes": 8},
                "r2": 0.96,
                "rmsecv": 0.045,
                "chemin_fichier": "",
            },
        )
        if cree:
            self.stdout.write(f"Modèle de démonstration créé : {modele}")
        return modele

    @transaction.atomic
    def _seed_pour_utilisateur(self, utilisateur, modele, nombre):
        maintenant = timezone.now()

        for i in range(nombre):
            numero = f"{PREFIXE_DEMO}{utilisateur.pk}-{i + 1:04d}"
            if Echantillon.objects.filter(utilisateur=utilisateur, numero=numero).exists():
                continue

            # Répartition sur les ~45 derniers jours, avec une densité plus
            # forte sur les derniers jours pour un graphique 7 jours parlant.
            jours_ecoules = random.choices(
                population=range(46), weights=[3] * 7 + [1] * 39, k=1
            )[0]
            date_analyse = maintenant - timedelta(
                days=jours_ecoules, hours=random.randint(0, 23), minutes=random.randint(0, 59)
            )

            echantillon = Echantillon.objects.create(
                numero=numero,
                date_analyse=date_analyse,
                utilisateur=utilisateur,
                origine=random.choice(ORIGINES),
                variete=random.choice(VARIETES),
                notes="Échantillon de démonstration généré par seed_demo.",
            )

            self._creer_spectre_demo(echantillon, date_analyse)
            self._creer_resultat_demo(echantillon, modele, date_analyse)

    def _creer_spectre_demo(self, echantillon, date_analyse):
        # Plage NIR typique 900-1700 nm, valeurs d'absorbance plausibles.
        valeurs_x = [900 + i * 8 for i in range(100)]
        valeurs_y = [round(0.2 + random.random() * 0.6, 4) for _ in valeurs_x]
        contenu = json.dumps(valeurs_y).encode()

        Spectre.objects.create(
            echantillon=echantillon,
            valeurs_x=valeurs_x,
            valeurs_y=valeurs_y,
            nombre_series=len(valeurs_x),
            date_acquisition=date_analyse,
            checksum=hashlib.sha256(contenu).hexdigest(),
            taille_donnees=len(contenu),
        )

    def _creer_resultat_demo(self, echantillon, modele, date_analyse):
        _categorie, _poids, (borne_min, borne_max) = random.choices(
            BANDES_ACIDITE, weights=[b[1] for b in BANDES_ACIDITE], k=1
        )[0]
        acidite = Decimal(str(round(random.uniform(borne_min, borne_max), 3)))
        indice_peroxyde = Decimal(str(round(random.uniform(5, 22), 3)))
        conforme = acidite <= SEUIL_ACIDITE_DEFAUT and indice_peroxyde <= SEUIL_PEROXYDE_DEFAUT

        resultat = Resultat.objects.create(
            echantillon=echantillon,
            modele_utilise=modele,
            acidite=acidite,
            indice_peroxyde=indice_peroxyde,
            duree_analyse_secondes=random.randint(45, 240),
            conforme=conforme,
        )
        # date_calcul est auto_now_add : on la recale juste après la création
        # pour simuler un délai de traitement réaliste (quelques minutes).
        date_calcul = date_analyse + timedelta(minutes=random.randint(2, 12))
        Resultat.objects.filter(pk=resultat.pk).update(date_calcul=date_calcul)

    def _vider(self):
        resultats_supprimes, _ = Resultat.objects.filter(
            echantillon__numero__startswith=PREFIXE_DEMO
        ).delete()
        spectres_supprimes, _ = Spectre.objects.filter(
            echantillon__numero__startswith=PREFIXE_DEMO
        ).delete()
        echantillons_supprimes, _ = Echantillon.objects.filter(
            numero__startswith=PREFIXE_DEMO
        ).delete()
        modeles_supprimes, _ = Modele.objects.filter(nom=MODELE_DEMO_NOM).delete()

        self.stdout.write(
            self.style.SUCCESS(
                "Données de démonstration supprimées : "
                f"{echantillons_supprimes} échantillon(s), {spectres_supprimes} spectre(s), "
                f"{resultats_supprimes} résultat(s), {modeles_supprimes} modèle(s)."
            )
        )
