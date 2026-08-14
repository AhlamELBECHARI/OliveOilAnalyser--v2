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
from resultats.models import PredictionModele, Resultat
from spectres.models import Spectre

PREFIXE_DEMO = "DEMO-"

# Un scan est évalué par plusieurs modèles simultanément (voir Datas_Spect-
# Re_flec.xlsx, fichier de référence de l'encadrante) : deux modèles
# d'acidité (régression) et deux modèles de détection de mélange
# (classification), sur le même principe que M5/M7 et Mixing1/Mixing11.
# Un seul modèle "de référence" par grandeur pilote la synthèse écrite sur
# Resultat (voir resultats.services._deriver_synthese_depuis_predictions,
# répliqué manuellement ici puisque seed_demo écrit directement via l'ORM).
MODELES_DEMO = [
    {
        "nom": "PLS-M5",
        "version": "1.0",
        "algorithme": "PLS",
        "type_modele": "regression",
        "grandeur_predite": "acidite",
        "r2": 0.96,
        "rmsecv": 0.045,
        "est_reference": True,
    },
    {
        "nom": "PLS-M7",
        "version": "1.0",
        "algorithme": "PLS",
        "type_modele": "regression",
        "grandeur_predite": "acidite",
        "r2": 0.93,
        "rmsecv": 0.061,
        "est_reference": False,
    },
    {
        "nom": "RF-Mixing1",
        "version": "1.0",
        "algorithme": "RandomForest",
        "type_modele": "classification",
        "grandeur_predite": "authenticite",
        "exactitude": 0.94,
        "precision_classification": 0.92,
        "rappel": 0.90,
        "est_reference": True,
    },
    {
        "nom": "RF-Mixing11",
        "version": "1.0",
        "algorithme": "RandomForest",
        "type_modele": "classification",
        "grandeur_predite": "authenticite",
        "exactitude": 0.91,
        "precision_classification": 0.89,
        "rappel": 0.87,
        "est_reference": False,
    },
]
NOMS_MODELES_DEMO = [m["nom"] for m in MODELES_DEMO]

# Réplicats : un échantillon physique est en moyenne scanné 3 fois (voir
# fichier de référence) — le spectre acquis est partagé entre les réplicats
# (un seul Spectre par Echantillon, comme dans le flux réel de l'app), seule
# l'étape de prédiction est rejouée plusieurs fois.
POIDS_NOMBRE_REPLICATS = {2: 25, 3: 50, 4: 25}

# Proportion d'échantillons pour lesquels une mesure de référence labo a été
# saisie a posteriori (voir Resultat.acidite_reference et consorts) —
# volontairement partielle : en pratique, seule une partie des échantillons
# est effectivement re-mesurée au laboratoire.
PROPORTION_AVEC_REFERENCE_LABO = 0.3

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

PRODUCTEURS = [
    "Domaine Alami",
    "Coopérative Saada",
    "Domaine Atlas",
    "Domaine Al Waha",
    "Coopérative El Baraka",
    "Domaine Olivea",
]

# Centroïdes approximatifs (latitude, longitude) par région, avec une
# légère dispersion aléatoire à la génération — suffisant pour un jeu de
# démo permettant de tester le filtre "région" et l'affichage GPS, pas des
# coordonnées de parcelles réelles.
CENTROIDES_REGIONS = {
    "Marrakech-Safi": (31.6295, -7.9811),
    "Fès-Meknès": (34.0181, -5.0078),
    "Béni Mellal-Khénifra": (32.3373, -6.3498),
    "Rabat-Salé-Kénitra": (34.0209, -6.8416),
    "Souss-Massa": (30.4278, -9.5981),
}
REGIONS = list(CENTROIDES_REGIONS)

# Étendue sur laquelle les échantillons de démo sont répartis, pour que le
# regroupement par mois de l'écran Historique ait plusieurs mois distincts
# à afficher (et pas seulement le mois courant).
NOMBRE_JOURS_HISTORIQUE = 180

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
            default=60,
            help="Nombre d'échantillons de démonstration à générer par utilisateur (défaut 60).",
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

        modeles = self._obtenir_ou_creer_modeles_demo()
        modeles_regression = [m for m in modeles if m.type_modele == "regression"]
        modeles_classification = [m for m in modeles if m.type_modele == "classification"]
        modele_reference_acidite = next(m for m in modeles_regression if m.est_reference)

        for utilisateur in utilisateurs:
            self._seed_pour_utilisateur(
                utilisateur,
                modeles_regression=modeles_regression,
                modeles_classification=modeles_classification,
                modele_reference_acidite=modele_reference_acidite,
                nombre=options["nombre"],
            )

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

    def _obtenir_ou_creer_modeles_demo(self):
        modeles = []
        for donnees in MODELES_DEMO:
            modele, cree = Modele.objects.get_or_create(
                nom=donnees["nom"], version=donnees["version"], defaults=donnees
            )
            if cree:
                self.stdout.write(f"Modèle de démonstration créé : {modele}")
            modeles.append(modele)
        return modeles

    @transaction.atomic
    def _seed_pour_utilisateur(
        self, utilisateur, *, modeles_regression, modeles_classification, modele_reference_acidite, nombre
    ):
        maintenant = timezone.now()

        for i in range(nombre):
            numero = f"{PREFIXE_DEMO}{utilisateur.pk}-{i + 1:04d}"
            if Echantillon.objects.filter(utilisateur=utilisateur, numero=numero).exists():
                continue

            # Répartition sur les NOMBRE_JOURS_HISTORIQUE derniers jours (~6
            # mois), avec une densité plus forte sur les 7 derniers jours
            # pour que le graphique 7 jours du dashboard reste parlant, tout
            # en couvrant plusieurs mois distincts pour l'écran Historique.
            jours_ecoules = random.choices(
                population=range(NOMBRE_JOURS_HISTORIQUE + 1),
                weights=[3] * 7 + [1] * (NOMBRE_JOURS_HISTORIQUE - 6),
                k=1,
            )[0]
            date_analyse = maintenant - timedelta(
                days=jours_ecoules, hours=random.randint(0, 23), minutes=random.randint(0, 59)
            )
            date_recolte = date_analyse.date() - timedelta(days=random.randint(3, 25))

            region = random.choice(REGIONS)
            latitude_base, longitude_base = CENTROIDES_REGIONS[region]
            latitude = Decimal(str(round(latitude_base + random.uniform(-0.15, 0.15), 6)))
            longitude = Decimal(str(round(longitude_base + random.uniform(-0.15, 0.15), 6)))

            echantillon = Echantillon.objects.create(
                numero=numero,
                date_analyse=date_analyse,
                utilisateur=utilisateur,
                origine=random.choice(ORIGINES),
                variete=random.choice(VARIETES),
                producteur=random.choice(PRODUCTEURS),
                region=region,
                date_recolte=date_recolte,
                latitude=latitude,
                longitude=longitude,
                notes="Échantillon de démonstration généré par seed_demo.",
            )

            # Un seul spectre acquis par échantillon (comme dans le flux réel
            # de l'app — voir features/nouvelle_analyse côté Flutter) ; les
            # réplicats rejouent l'étape de prédiction sur ce même spectre.
            self._creer_spectre_demo(echantillon, date_analyse)

            a_reference_labo = random.random() < PROPORTION_AVEC_REFERENCE_LABO
            valeurs_reference = (
                self._generer_valeurs_reference_labo() if a_reference_labo else None
            )

            nombre_replicats = random.choices(
                population=list(POIDS_NOMBRE_REPLICATS),
                weights=list(POIDS_NOMBRE_REPLICATS.values()),
                k=1,
            )[0]
            for numero_replicat in range(1, nombre_replicats + 1):
                self._creer_resultat_demo(
                    echantillon,
                    modeles_regression=modeles_regression,
                    modeles_classification=modeles_classification,
                    modele_reference_acidite=modele_reference_acidite,
                    date_analyse=date_analyse,
                    numero_replicat=numero_replicat,
                    valeurs_reference=valeurs_reference,
                )

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

    def _generer_valeurs_reference_labo(self):
        """Mesure de laboratoire simulée, indépendante des prédictions —
        c'est justement l'écart entre les deux qui rend le bloc
        "Comparaison avec la référence laboratoire" intéressant à visualiser
        en démo plutôt qu'un accord parfait."""
        _categorie, _poids, (borne_min, borne_max) = random.choices(
            BANDES_ACIDITE, weights=[b[1] for b in BANDES_ACIDITE], k=1
        )[0]
        return {
            "acidite_reference": Decimal(str(round(random.uniform(borne_min, borne_max), 3))),
            "indice_peroxyde_reference": Decimal(str(round(random.uniform(5, 22), 3))),
            "authenticite_reference": "pure" if random.random() < 0.85 else "melangee",
            "date_mesure_reference": timezone.now().date() - timedelta(days=random.randint(1, 10)),
        }

    def _creer_resultat_demo(
        self,
        echantillon,
        *,
        modeles_regression,
        modeles_classification,
        modele_reference_acidite,
        date_analyse,
        numero_replicat,
        valeurs_reference,
    ):
        _categorie, _poids, (borne_min, borne_max) = random.choices(
            BANDES_ACIDITE, weights=[b[1] for b in BANDES_ACIDITE], k=1
        )[0]
        acidite_vraie = round(random.uniform(borne_min, borne_max), 3)
        indice_peroxyde = Decimal(str(round(random.uniform(5, 22), 3)))
        estime_pure = random.random() < 0.85

        # Chaque valeur/verdict est tiré UNE SEULE FOIS par modèle, pour que
        # la synthèse écrite sur Resultat corresponde exactement à la
        # prédiction du modèle de référence (voir
        # resultats.services._deriver_synthese_depuis_predictions) plutôt
        # que d'être un second tirage indépendant.
        valeurs_regression = {
            modele: self._valeur_avec_bruit(acidite_vraie, ampleur=0.03) for modele in modeles_regression
        }
        confiances_classification = {
            modele: round(random.uniform(0.85, 0.99) if estime_pure else random.uniform(0.55, 0.9), 3)
            for modele in modeles_classification
        }

        acidite_retenue = valeurs_regression[modele_reference_acidite]
        conforme = acidite_retenue <= SEUIL_ACIDITE_DEFAUT and indice_peroxyde <= SEUIL_PEROXYDE_DEFAUT

        donnees_reference = valeurs_reference or {}
        resultat = Resultat.objects.create(
            echantillon=echantillon,
            modele_utilise=modele_reference_acidite,
            acidite=acidite_retenue,
            indice_peroxyde=indice_peroxyde,
            duree_analyse_secondes=random.randint(45, 240),
            conforme=conforme,
            numero_replicat=numero_replicat,
            **donnees_reference,
        )
        # date_calcul est auto_now_add : on la recale juste après la création
        # pour simuler un délai de traitement réaliste (quelques minutes),
        # décalé par réplicat pour que l'ordre chronologique reste cohérent.
        date_calcul = date_analyse + timedelta(minutes=random.randint(2, 12) * numero_replicat)
        Resultat.objects.filter(pk=resultat.pk).update(date_calcul=date_calcul)

        predictions = [
            PredictionModele(resultat=resultat, modele=modele, valeur_numerique=valeur)
            for modele, valeur in valeurs_regression.items()
        ] + [
            PredictionModele(
                resultat=resultat,
                modele=modele,
                classe_predite="pure" if estime_pure else "melangee",
                score_confiance=confiance,
            )
            for modele, confiance in confiances_classification.items()
        ]
        PredictionModele.objects.bulk_create(predictions)

    def _valeur_avec_bruit(self, valeur_base, *, ampleur):
        return Decimal(str(round(valeur_base + random.uniform(-ampleur, ampleur), 3)))

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
        modeles_supprimes, _ = Modele.objects.filter(nom__in=NOMS_MODELES_DEMO).delete()

        self.stdout.write(
            self.style.SUCCESS(
                "Données de démonstration supprimées : "
                f"{echantillons_supprimes} échantillon(s), {spectres_supprimes} spectre(s), "
                f"{resultats_supprimes} résultat(s) (et leurs prédictions), {modeles_supprimes} modèle(s)."
            )
        )
