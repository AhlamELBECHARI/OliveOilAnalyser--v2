from django.contrib.auth import password_validation
from rest_framework import serializers

from .models import Configuration, Utilisateur


class RegisterSerializer(serializers.Serializer):
    """
    Sérialiseur d'inscription publique. N'expose volontairement AUCUN champ
    de rôle/droits : role, is_staff et is_superuser sont forcés côté
    services.py, quoi que le client envoie.
    """

    nom = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)

    def validate_email(self, value):
        email = value.strip().lower()
        if Utilisateur.objects.filter(email=email).exists():
            raise serializers.ValidationError("Un compte existe déjà avec cet email.")
        return email

    def validate(self, attrs):
        if attrs["password"] != attrs["password2"]:
            raise serializers.ValidationError(
                {"password2": "Les mots de passe ne correspondent pas."}
            )
        password_validation.validate_password(attrs["password"])
        return attrs


class CreerAdministrateurSerializer(RegisterSerializer):
    """Même validation de format que l'inscription publique ; le rôle
    administrateur est forcé côté services.py. Réservé aux vues protégées
    par IsAdministrateur."""


class UtilisateurSerializer(serializers.ModelSerializer):
    date_derniere_connexion = serializers.DateTimeField(source="last_login", read_only=True)

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "nom",
            "email",
            "role",
            "est_actif",
            "is_staff",
            "tentatives_echouees",
            "verrouille_jusqu_a",
            "date_derniere_connexion",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = fields


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, trim_whitespace=False)


class LoginResponseSerializer(serializers.Serializer):
    """Documentation uniquement (drf-spectacular) : forme de la réponse de
    POST /api/auth/login/, jamais utilisée pour valider une entrée."""

    access = serializers.CharField()
    refresh = serializers.CharField()
    utilisateur = UtilisateurSerializer()


class DemandeResetMotDePasseSerializer(serializers.Serializer):
    email = serializers.EmailField()


class _CodeResetMixin:
    def validate_code(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Le code doit contenir 6 chiffres.")
        return value


class VerifierCodeResetSerializer(_CodeResetMixin, serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(min_length=6, max_length=6)


class ConfirmerResetMotDePasseSerializer(_CodeResetMixin, serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(min_length=6, max_length=6)
    nouveau_mot_de_passe = serializers.CharField(write_only=True, min_length=8)

    def validate_nouveau_mot_de_passe(self, value):
        password_validation.validate_password(value)
        return value


class ConfigurationSerializer(serializers.ModelSerializer):
    modifie_par = UtilisateurSerializer(read_only=True)

    class Meta:
        model = Configuration
        fields = [
            "id",
            "notifications_actives",
            "seuil_conformite_acidite",
            "seuil_conformite_peroxyde",
            "seuil_acidite_evoo",
            "seuil_acidite_voo",
            "est_actif",
            "modifie_par",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "modifie_par", "date_creation", "date_modification"]
