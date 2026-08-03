from rest_framework import serializers

from .models import Modele


class ModeleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Modele
        fields = [
            "id",
            "nom",
            "version",
            "algorithme",
            "hyperparametres",
            "r2",
            "rmsecv",
            "est_actif",
            "est_deprecie",
            "chemin_fichier",
            "date_entrainement",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "date_creation", "date_modification"]

    def validate_rmsecv(self, value):
        if value < 0:
            raise serializers.ValidationError("rmsecv doit être positif ou nul.")
        return value
