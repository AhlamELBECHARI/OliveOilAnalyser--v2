from rest_framework import serializers

from .models import Spectre


class SpectreSerializer(serializers.ModelSerializer):
    # Voir EchantillonSerializer.id : UUID généré côté mobile, accepté tel
    # quel pour que la synchronisation hors ligne soit idempotente.
    id = serializers.UUIDField(required=False)

    class Meta:
        model = Spectre
        fields = [
            "id",
            "echantillon",
            "valeurs_x",
            "valeurs_y",
            "nombre_series",
            "date_acquisition",
            "checksum",
            "taille_donnees",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["date_creation", "date_modification"]

    def validate(self, attrs):
        valeurs_x = attrs.get("valeurs_x", getattr(self.instance, "valeurs_x", None))
        valeurs_y = attrs.get("valeurs_y", getattr(self.instance, "valeurs_y", None))
        nombre_series = attrs.get(
            "nombre_series", getattr(self.instance, "nombre_series", None)
        )

        if not isinstance(valeurs_x, list) or not isinstance(valeurs_y, list):
            raise serializers.ValidationError(
                {"valeurs_x": "valeurs_x et valeurs_y doivent être des listes de valeurs."}
            )
        if len(valeurs_x) != len(valeurs_y) or len(valeurs_x) != nombre_series:
            raise serializers.ValidationError(
                "valeurs_x, valeurs_y et nombre_series doivent avoir la même longueur."
            )
        return attrs
