from rest_framework import serializers

from .models import Echantillon


class EchantillonSerializer(serializers.ModelSerializer):
    # UUID généré côté mobile (voir la couche de synchronisation hors ligne
    # Drift du frontend) : accepté tel quel à la création pour que l'ID
    # local et l'ID serveur soient identiques dès l'écriture locale, sans
    # collision possible. `required=False` : un client qui n'en fournit pas
    # (admin, tests...) obtient toujours l'UUID auto-généré du modèle.
    id = serializers.UUIDField(required=False)
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
            "variete",
            "producteur",
            "region",
            "date_recolte",
            "latitude",
            "longitude",
            "notes",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["utilisateur", "date_creation", "date_modification"]

    def validate_latitude(self, value):
        if value is not None and not (-90 <= value <= 90):
            raise serializers.ValidationError("La latitude doit être comprise entre -90 et 90.")
        return value

    def validate_longitude(self, value):
        if value is not None and not (-180 <= value <= 180):
            raise serializers.ValidationError(
                "La longitude doit être comprise entre -180 et 180."
            )
        return value
