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


class DemandeResetMotDePasseSerializer(serializers.Serializer):
    email = serializers.EmailField()


class ConfirmerResetMotDePasseSerializer(serializers.Serializer):
    token = serializers.CharField()
    nouveau_mot_de_passe = serializers.CharField(write_only=True, min_length=8)
    nouveau_mot_de_passe2 = serializers.CharField(write_only=True, min_length=8)

    def validate(self, attrs):
        if attrs["nouveau_mot_de_passe"] != attrs["nouveau_mot_de_passe2"]:
            raise serializers.ValidationError(
                {"nouveau_mot_de_passe2": "Les mots de passe ne correspondent pas."}
            )
        password_validation.validate_password(attrs["nouveau_mot_de_passe"])
        return attrs


class ConfigurationSerializer(serializers.ModelSerializer):
    modifie_par = UtilisateurSerializer(read_only=True)

    class Meta:
        model = Configuration
        fields = [
            "id",
            "notifications_actives",
            "seuil_conformite_acidite",
            "seuil_conformite_peroxyde",
            "est_actif",
            "modifie_par",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "modifie_par", "date_creation", "date_modification"]
