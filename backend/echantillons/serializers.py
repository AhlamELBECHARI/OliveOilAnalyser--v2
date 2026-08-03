from rest_framework import serializers

from .models import Echantillon


class EchantillonSerializer(serializers.ModelSerializer):
    utilisateur_email = serializers.EmailField(source="utilisateur.email", read_only=True)

    class Meta:
        model = Echantillon
        fields = [
            "id",
            "numero",
            "date_analyse",
            "utilisateur",
            "utilisateur_email",
            "origine",
            "notes",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "utilisateur", "date_creation", "date_modification"]
