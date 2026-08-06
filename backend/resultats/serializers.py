from rest_framework import serializers

from .models import Resultat


class ResultatSerializer(serializers.ModelSerializer):
    # Voir EchantillonSerializer.id : UUID généré côté mobile, accepté tel
    # quel pour que la synchronisation hors ligne soit idempotente.
    id = serializers.UUIDField(required=False)
    # Champs de confort en lecture seule, pour éviter à un client (l'écran
    # Historique du frontend, par ex.) une seconde requête sur /echantillons/
    # juste pour afficher le numéro/la variété/l'origine de l'échantillon.
    numero_echantillon = serializers.CharField(source="echantillon.numero", read_only=True)
    variete_echantillon = serializers.CharField(source="echantillon.variete", read_only=True)
    origine_echantillon = serializers.CharField(source="echantillon.origine", read_only=True)

    class Meta:
        model = Resultat
        fields = [
            "id",
            "echantillon",
            "numero_echantillon",
            "variete_echantillon",
            "origine_echantillon",
            "modele_utilise",
            "acidite",
            "indice_peroxyde",
            "date_calcul",
            "duree_analyse_secondes",
            "conforme",
            "commentaire",
            "valide_par",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["date_calcul", "date_creation", "date_modification"]

    def validate_acidite(self, value):
        if value < 0:
            raise serializers.ValidationError("L'acidité doit être positive ou nulle.")
        return value

    def validate_indice_peroxyde(self, value):
        if value < 0:
            raise serializers.ValidationError("L'indice de peroxyde doit être positif ou nul.")
        return value
