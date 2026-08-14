from rest_framework import serializers

from .models import JournalAudit


class JournalAuditSerializer(serializers.ModelSerializer):
    acteur_nom = serializers.CharField(source="acteur.nom", read_only=True, default=None)
    acteur_email = serializers.CharField(source="acteur.email", read_only=True, default=None)
    action_libelle = serializers.CharField(source="get_action_display", read_only=True)

    class Meta:
        model = JournalAudit
        fields = [
            "id",
            "action",
            "action_libelle",
            "acteur_nom",
            "acteur_email",
            "cible_type",
            "cible_id",
            "details",
            "date_creation",
        ]
        read_only_fields = fields


# --- Supervision ---


class EtatSystemeSerializer(serializers.Serializer):
    api_disponible = serializers.BooleanField()
    base_de_donnees_disponible = serializers.BooleanField()
    taille_base_octets = serializers.IntegerField()
    date_derniere_sauvegarde = serializers.DateTimeField(allow_null=True)
    nombre_analyseurs_recents = serializers.IntegerField(allow_null=True)


class ActiviteJourSerializer(serializers.Serializer):
    utilisateurs_connectes = serializers.IntegerField()
    sessions_actives = serializers.IntegerField()
    analyses_aujourd_hui = serializers.IntegerField()
    analyses_cette_semaine = serializers.IntegerField()
    variation_pourcentage = serializers.FloatField(allow_null=True)


class AlerteSupervisionSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    type = serializers.CharField()
    message = serializers.CharField()
    niveau_gravite = serializers.CharField()
    date_creation = serializers.DateTimeField()
    numero_echantillon = serializers.SerializerMethodField()

    def get_numero_echantillon(self, alerte) -> str | None:
        return alerte.echantillon.numero if alerte.echantillon else None


class ActiviteOperateurSerializer(serializers.Serializer):
    utilisateur_id = serializers.IntegerField()
    nom = serializers.CharField()
    email = serializers.CharField()
    nombre_analyses = serializers.IntegerField()
    repartition_qualite = serializers.DictField(child=serializers.IntegerField())
    derniere_activite = serializers.DateTimeField(allow_null=True)


class AnomaliesSerializer(serializers.Serializer):
    comptes_verrouilles = serializers.IntegerField()
    echecs_synchronisation = serializers.IntegerField(allow_null=True)
    resultats_en_erreur = serializers.IntegerField(allow_null=True)
    modeles_deprecies_references = serializers.IntegerField()


class SupervisionSerializer(serializers.Serializer):
    etat_systeme = EtatSystemeSerializer()
    activite_jour = ActiviteJourSerializer()
    alertes_non_resolues = AlerteSupervisionSerializer(many=True)
    activite_par_operateur = ActiviteOperateurSerializer(many=True)
    anomalies = AnomaliesSerializer()


# --- Gestion des données ---


class StatistiquesOccupationSerializer(serializers.Serializer):
    echantillons = serializers.IntegerField()
    spectres = serializers.IntegerField()
    resultats = serializers.IntegerField()
    modeles = serializers.IntegerField()
    utilisateurs = serializers.IntegerField()
    taille_base_octets = serializers.IntegerField()


class PurgeDemandeSerializer(serializers.Serializer):
    date_limite = serializers.DateField()


class PurgeApercuSerializer(serializers.Serializer):
    echantillons_a_supprimer = serializers.IntegerField()
    spectres_a_supprimer = serializers.IntegerField()
    resultats_a_supprimer = serializers.IntegerField()


class PurgeResultatSerializer(serializers.Serializer):
    echantillons_supprimes = serializers.IntegerField()
    spectres_supprimes = serializers.IntegerField()
    resultats_supprimes = serializers.IntegerField()
