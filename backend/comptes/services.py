"""
Toute la logique métier de l'app comptes : inscription, authentification,
verrouillage de compte, réinitialisation de mot de passe, configuration
globale. Les vues n'appellent que les fonctions de ce module.
"""

import hashlib
import secrets
from datetime import timedelta
from decimal import Decimal

from django.conf import settings
from django.core.mail import send_mail
from django.db import transaction
from django.utils import timezone
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken, OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from core.exceptions import (
    CodeResetInvalideError,
    CompteDesactiveError,
    CompteVerrouilleError,
    IdentifiantsInvalidesError,
    TropDeDemandesError,
)

from .models import Configuration, Utilisateur

SEUIL_ACIDITE_DEFAUT = Decimal("0.8")
SEUIL_PEROXYDE_DEFAUT = Decimal("20.000")
# Seuils par défaut de classification qualité (norme du Conseil Oléicole
# International) : EVOO <= 0.8 %, VOO <= 2.0 %, au-delà Lampante.
SEUIL_EVOO_DEFAUT = Decimal("0.800")
SEUIL_VOO_DEFAUT = Decimal("2.000")


# --- Inscription / création de comptes ------------------------------------

def inscrire_utilisateur(*, nom, email, password, **_ignore):
    """Crée un compte utilisateur standard. Le rôle et les droits d'accès
    admin sont toujours forcés côté serveur, quoi que le client envoie."""
    return Utilisateur.objects.create_user(
        email=email,
        nom=nom,
        password=password,
        role=Utilisateur.Role.UTILISATEUR,
        is_staff=False,
        is_superuser=False,
    )


def creer_administrateur(*, nom, email, password, **_ignore):
    """Réservé aux administrateurs déjà authentifiés (permission IsAdministrateur
    appliquée dans la vue)."""
    return Utilisateur.objects.create_user(
        email=email,
        nom=nom,
        password=password,
        role=Utilisateur.Role.ADMINISTRATEUR,
        is_staff=True,
        is_superuser=False,
    )


def lister_utilisateurs():
    return Utilisateur.objects.all()


# --- Connexion, verrouillage de compte -------------------------------------

def _generer_tokens(utilisateur):
    refresh = RefreshToken.for_user(utilisateur)
    return {"access": str(refresh.access_token), "refresh": str(refresh)}


def _deverrouiller_si_expire(utilisateur):
    """Déverrouillage automatique : dès que verrouille_jusqu_a est dépassé,
    le compteur d'échecs est réinitialisé au prochain contrôle (ici, à la
    prochaine tentative de connexion)."""
    if utilisateur.verrouille_jusqu_a and utilisateur.verrouille_jusqu_a <= timezone.now():
        utilisateur.verrouille_jusqu_a = None
        utilisateur.tentatives_echouees = 0
        utilisateur.save(update_fields=["verrouille_jusqu_a", "tentatives_echouees"])


def _enregistrer_echec(utilisateur):
    utilisateur.tentatives_echouees += 1
    if utilisateur.tentatives_echouees >= settings.MAX_TENTATIVES_ECHOUEES:
        utilisateur.verrouille_jusqu_a = timezone.now() + timedelta(
            minutes=settings.DUREE_VERROUILLAGE_MINUTES
        )
    utilisateur.save(update_fields=["tentatives_echouees", "verrouille_jusqu_a"])


def _enregistrer_succes(utilisateur):
    utilisateur.tentatives_echouees = 0
    utilisateur.verrouille_jusqu_a = None
    utilisateur.last_login = timezone.now()
    utilisateur.save(update_fields=["tentatives_echouees", "verrouille_jusqu_a", "last_login"])


def login(*, email, password):
    email = (email or "").strip().lower()
    try:
        utilisateur = Utilisateur.objects.get(email=email)
    except Utilisateur.DoesNotExist:
        raise IdentifiantsInvalidesError()

    _deverrouiller_si_expire(utilisateur)

    if utilisateur.verrouille_jusqu_a and utilisateur.verrouille_jusqu_a > timezone.now():
        raise CompteVerrouilleError()

    if not utilisateur.est_actif:
        raise CompteDesactiveError()

    if not utilisateur.check_password(password):
        _enregistrer_echec(utilisateur)
        raise IdentifiantsInvalidesError()

    _enregistrer_succes(utilisateur)
    tokens = _generer_tokens(utilisateur)
    return {**tokens, "utilisateur": utilisateur}


# --- Réinitialisation de mot de passe (code à 6 chiffres) ------------------

def _hash_code(code):
    return hashlib.sha256(code.encode()).hexdigest()


def _generer_code():
    """Code numérique à 6 chiffres, généré via un CSPRNG (pas `random`)."""
    return f"{secrets.randbelow(1_000_000):06d}"


def _blacklister_tokens_utilisateur(utilisateur):
    """Invalide tous les refresh tokens en circulation pour cet utilisateur
    (changement de mot de passe ou désactivation de compte)."""
    for outstanding in OutstandingToken.objects.filter(user=utilisateur):
        BlacklistedToken.objects.get_or_create(token=outstanding)


def _verifier_et_incrementer_limite_demandes(utilisateur):
    """Anti-abus : limite le nombre de codes qu'un même compte peut demander
    sur une fenêtre glissante (évite le spam d'emails)."""
    maintenant = timezone.now()
    fenetre = timedelta(minutes=settings.FENETRE_DEMANDES_CODE_RESET_MINUTES)

    fenetre_expiree = (
        utilisateur.code_reset_demande_fenetre_debut is None
        or maintenant - utilisateur.code_reset_demande_fenetre_debut > fenetre
    )
    if fenetre_expiree:
        utilisateur.code_reset_demande_fenetre_debut = maintenant
        utilisateur.code_reset_demandes_compteur = 0

    if utilisateur.code_reset_demandes_compteur >= settings.MAX_DEMANDES_CODE_RESET_PAR_FENETRE:
        raise TropDeDemandesError()

    utilisateur.code_reset_demandes_compteur += 1
    utilisateur.save(
        update_fields=["code_reset_demande_fenetre_debut", "code_reset_demandes_compteur"]
    )


def demander_reset_mot_de_passe(*, email):
    email = (email or "").strip().lower()
    try:
        utilisateur = Utilisateur.objects.get(email=email, est_actif=True)
    except Utilisateur.DoesNotExist:
        # Ne jamais révéler si un compte existe pour cet email ou non.
        return

    _verifier_et_incrementer_limite_demandes(utilisateur)

    code_clair = _generer_code()
    utilisateur.code_reset_mot_de_passe_hash = _hash_code(code_clair)
    utilisateur.code_reset_expiration = timezone.now() + timedelta(
        minutes=settings.DUREE_VALIDITE_CODE_RESET_MINUTES
    )
    utilisateur.code_reset_tentatives_echouees = 0
    utilisateur.save(
        update_fields=[
            "code_reset_mot_de_passe_hash",
            "code_reset_expiration",
            "code_reset_tentatives_echouees",
        ]
    )

    send_mail(
        subject="Olive IQ — Code de réinitialisation de votre mot de passe",
        message=(
            "Voici votre code de réinitialisation de mot de passe :\n\n"
            f"{code_clair}\n\n"
            f"Ce code est valable {settings.DUREE_VALIDITE_CODE_RESET_MINUTES} minutes.\n"
            "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email."
        ),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[utilisateur.email],
        fail_silently=True,
    )


def _obtenir_utilisateur_avec_code_actif(email):
    try:
        return Utilisateur.objects.get(
            email=email,
            code_reset_expiration__gt=timezone.now(),
        )
    except Utilisateur.DoesNotExist:
        return None


def _verifier_code(utilisateur, code):
    """Compare le code fourni au hash stocké. Au-delà de
    MAX_TENTATIVES_CODE_RESET essais infructueux, invalide le code en cours
    (l'utilisateur devra en redemander un) — protège un code à 6 chiffres
    dont l'espace de recherche est trop petit pour être laissé sans limite."""
    if utilisateur.code_reset_mot_de_passe_hash != _hash_code(code):
        utilisateur.code_reset_tentatives_echouees += 1
        champs = ["code_reset_tentatives_echouees"]
        if utilisateur.code_reset_tentatives_echouees >= settings.MAX_TENTATIVES_CODE_RESET:
            utilisateur.code_reset_mot_de_passe_hash = ""
            utilisateur.code_reset_expiration = None
            champs += ["code_reset_mot_de_passe_hash", "code_reset_expiration"]
        utilisateur.save(update_fields=champs)
        return False
    return True


def verifier_code_reset(*, email, code):
    email = (email or "").strip().lower()
    utilisateur = _obtenir_utilisateur_avec_code_actif(email)
    if utilisateur is None or not _verifier_code(utilisateur, code):
        raise CodeResetInvalideError()


@transaction.atomic
def confirmer_reset_mot_de_passe(*, email, code, nouveau_mot_de_passe):
    email = (email or "").strip().lower()
    utilisateur = _obtenir_utilisateur_avec_code_actif(email)
    if utilisateur is None or not _verifier_code(utilisateur, code):
        raise CodeResetInvalideError()

    utilisateur.set_password(nouveau_mot_de_passe)
    utilisateur.code_reset_mot_de_passe_hash = ""
    utilisateur.code_reset_expiration = None
    utilisateur.code_reset_tentatives_echouees = 0
    utilisateur.code_reset_demandes_compteur = 0
    utilisateur.code_reset_demande_fenetre_debut = None
    utilisateur.tentatives_echouees = 0
    utilisateur.verrouille_jusqu_a = None
    utilisateur.save(
        update_fields=[
            "password",
            "code_reset_mot_de_passe_hash",
            "code_reset_expiration",
            "code_reset_tentatives_echouees",
            "code_reset_demandes_compteur",
            "code_reset_demande_fenetre_debut",
            "tentatives_echouees",
            "verrouille_jusqu_a",
        ]
    )
    _blacklister_tokens_utilisateur(utilisateur)
    return utilisateur


# --- Configuration globale (singleton) --------------------------------------

def obtenir_configuration():
    configuration, _ = Configuration.objects.get_or_create(
        pk=1,
        defaults={
            "seuil_conformite_acidite": SEUIL_ACIDITE_DEFAUT,
            "seuil_conformite_peroxyde": SEUIL_PEROXYDE_DEFAUT,
            "seuil_acidite_evoo": SEUIL_EVOO_DEFAUT,
            "seuil_acidite_voo": SEUIL_VOO_DEFAUT,
        },
    )
    return configuration


def mettre_a_jour_configuration(*, utilisateur, **champs):
    configuration = obtenir_configuration()
    champs_autorises = {
        "notifications_actives",
        "seuil_conformite_acidite",
        "seuil_conformite_peroxyde",
        "seuil_acidite_evoo",
        "seuil_acidite_voo",
        "est_actif",
    }
    for champ, valeur in champs.items():
        if champ in champs_autorises:
            setattr(configuration, champ, valeur)
    configuration.modifie_par = utilisateur
    configuration.save()
    return configuration
