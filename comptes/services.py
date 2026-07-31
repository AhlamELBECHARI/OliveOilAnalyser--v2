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
from rest_framework.exceptions import AuthenticationFailed, ValidationError
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken, OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Configuration, Utilisateur

SEUIL_ACIDITE_DEFAUT = Decimal("0.8")
SEUIL_PEROXYDE_DEFAUT = Decimal("20.000")


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
        raise AuthenticationFailed("Identifiants invalides.")

    _deverrouiller_si_expire(utilisateur)

    if utilisateur.verrouille_jusqu_a and utilisateur.verrouille_jusqu_a > timezone.now():
        raise AuthenticationFailed(
            "Compte temporairement verrouillé suite à plusieurs échecs de "
            "connexion. Réessayez plus tard."
        )

    if not utilisateur.est_actif:
        raise AuthenticationFailed("Ce compte est désactivé.")

    if not utilisateur.check_password(password):
        _enregistrer_echec(utilisateur)
        raise AuthenticationFailed("Identifiants invalides.")

    _enregistrer_succes(utilisateur)
    tokens = _generer_tokens(utilisateur)
    return {**tokens, "utilisateur": utilisateur}


# --- Réinitialisation de mot de passe --------------------------------------

def _hash_token(token):
    return hashlib.sha256(token.encode()).hexdigest()


def _blacklister_tokens_utilisateur(utilisateur):
    """Invalide tous les refresh tokens en circulation pour cet utilisateur
    (changement de mot de passe ou désactivation de compte)."""
    for outstanding in OutstandingToken.objects.filter(user=utilisateur):
        BlacklistedToken.objects.get_or_create(token=outstanding)


def demander_reset_mot_de_passe(*, email):
    email = (email or "").strip().lower()
    try:
        utilisateur = Utilisateur.objects.get(email=email, est_actif=True)
    except Utilisateur.DoesNotExist:
        # Ne jamais révéler si un compte existe pour cet email ou non.
        return

    token_clair = secrets.token_urlsafe(32)
    utilisateur.token_reset_mot_de_passe_hash = _hash_token(token_clair)
    utilisateur.token_reset_expiration = timezone.now() + timedelta(
        minutes=settings.DUREE_VALIDITE_TOKEN_RESET_MINUTES
    )
    utilisateur.save(update_fields=["token_reset_mot_de_passe_hash", "token_reset_expiration"])

    if settings.FRONTEND_RESET_PASSWORD_URL:
        contenu = f"{settings.FRONTEND_RESET_PASSWORD_URL}?token={token_clair}"
    else:
        contenu = token_clair

    send_mail(
        subject="Olive IQ — Réinitialisation de votre mot de passe",
        message=(
            "Vous avez demandé la réinitialisation de votre mot de passe.\n\n"
            f"Token (valable {settings.DUREE_VALIDITE_TOKEN_RESET_MINUTES} minutes) : "
            f"{contenu}\n\n"
            "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email."
        ),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[utilisateur.email],
        fail_silently=True,
    )


@transaction.atomic
def confirmer_reset_mot_de_passe(*, token, nouveau_mot_de_passe):
    token_hash = _hash_token(token)
    try:
        utilisateur = Utilisateur.objects.get(
            token_reset_mot_de_passe_hash=token_hash,
            token_reset_expiration__gt=timezone.now(),
        )
    except Utilisateur.DoesNotExist:
        raise ValidationError({"token": "Token invalide ou expiré."})

    utilisateur.set_password(nouveau_mot_de_passe)
    utilisateur.token_reset_mot_de_passe_hash = ""
    utilisateur.token_reset_expiration = None
    utilisateur.tentatives_echouees = 0
    utilisateur.verrouille_jusqu_a = None
    utilisateur.save(
        update_fields=[
            "password",
            "token_reset_mot_de_passe_hash",
            "token_reset_expiration",
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
        },
    )
    return configuration


def mettre_a_jour_configuration(*, utilisateur, **champs):
    configuration = obtenir_configuration()
    champs_autorises = {
        "notifications_actives",
        "seuil_conformite_acidite",
        "seuil_conformite_peroxyde",
        "est_actif",
    }
    for champ, valeur in champs.items():
        if champ in champs_autorises:
            setattr(configuration, champ, valeur)
    configuration.modifie_par = utilisateur
    configuration.save()
    return configuration
