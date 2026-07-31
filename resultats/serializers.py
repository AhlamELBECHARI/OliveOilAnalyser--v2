from rest_framework import serializers

from .models import Resultat


class ResultatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Resultat
        fields = [
            "id",
            "echantillon",
            "modele_utilise",
            "acidite",
            "indice_peroxyde",
            "date_calcul",
            "conforme",
            "commentaire",
            "valide_par",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "date_calcul", "date_creation", "date_modification"]

    def validate_acidite(self, value):
        if value < 0:
            raise serializers.ValidationError("L'acidité doit être positive ou nulle.")
        return value

    def validate_indice_peroxyde(self, value):
        if value < 0:
            raise serializers.ValidationError("L'indice de peroxyde doit être positif ou nul.")
        return value
