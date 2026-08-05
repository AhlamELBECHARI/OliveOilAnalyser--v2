from rest_framework import serializers

from .models import Alerte


class AlerteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alerte
        fields = [
            "id",
            "echantillon",
            "type",
            "message",
            "niveau_gravite",
            "date_creation",
            "est_resolue",
            "date_resolution",
            "resolue_par",
            "date_modification",
        ]
        read_only_fields = fields
