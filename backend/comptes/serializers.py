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


class MonProfilSerializer(serializers.ModelSerializer):
    """GET/PATCH /api/utilisateurs/moi/ — un utilisateur consulte et modifie
    son propre profil. `role`, `is_staff` et `is_superuser` sont
    volontairement absents des champs modifiables : même envoyés par le
    client, ils sont ignorés (voir comptes.services.modifier_profil, qui ne
    reprend que les champs listés dans read_only_fields en dehors)."""

    date_derniere_connexion = serializers.DateTimeField(source="last_login", read_only=True)

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "nom",
            "email",
            "role",
            "telephone",
            "fonction",
            "laboratoire",
            "institution",
            "photo_profil",
            "date_derniere_connexion",
            "date_creation",
        ]
        read_only_fields = ["id", "email", "role", "date_derniere_connexion", "date_creation"]


class ChangerMotDePasseSerializer(serializers.Serializer):
    ancien_mot_de_passe = serializers.CharField(write_only=True, trim_whitespace=False)
    nouveau_mot_de_passe = serializers.CharField(write_only=True, min_length=8)

    def validate_nouveau_mot_de_passe(self, value):
        password_validation.validate_password(value)
        return value


class SessionSerializer(serializers.Serializer):
    """Une session active = un refresh token émis (OutstandingToken) ni
    blacklisté ni expiré (voir comptes.services.lister_sessions).
    `est_courante` est calculé côté service à partir du jti que le client
    fournit lui-même (celui de son propre refresh token), jamais deviné
    côté serveur."""

    id = serializers.IntegerField()
    date_creation = serializers.DateTimeField(source="created_at")
    date_expiration = serializers.DateTimeField(source="expires_at")
    est_courante = serializers.BooleanField()


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


class UtilisateurAdminSerializer(serializers.ModelSerializer):
    """Vue détaillée réservée à l'espace admin (voir GET
    /api/admin/utilisateurs/) — ajoute le nombre d'analyses, absent de
    UtilisateurSerializer (qui reste utilisé ailleurs sans ce coût de
    requête supplémentaire)."""

    date_derniere_connexion = serializers.DateTimeField(source="last_login", read_only=True)
    nombre_analyses = serializers.SerializerMethodField()

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
            "nombre_analyses",
        ]
        read_only_fields = fields

    def get_nombre_analyses(self, utilisateur) -> int:
        from resultats.models import Resultat

        return Resultat.objects.filter(echantillon__utilisateur=utilisateur).count()


class ChangerRoleSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=Utilisateur.Role.choices)


class ActivationSerializer(serializers.Serializer):
    actif = serializers.BooleanField()


class CreerUtilisateurAdminSerializer(RegisterSerializer):
    """Même validation que l'inscription publique, avec un rôle choisi
    explicitement par l'administrateur plutôt que forcé à UTILISATEUR."""

    role = serializers.ChoiceField(choices=Utilisateur.Role.choices, default=Utilisateur.Role.UTILISATEUR)


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
