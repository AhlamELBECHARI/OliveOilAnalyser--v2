from rest_framework import serializers

from .models import Modele


class ModeleSerializer(serializers.ModelSerializer):
    fichier = serializers.FileField(required=False, allow_null=True)

    class Meta:
        model = Modele
        fields = [
            "id",
            "nom",
            "version",
            "algorithme",
            "hyperparametres",
            "type_modele",
            "grandeur_predite",
            "r2",
            "rmsecv",
            "exactitude",
            "precision_classification",
            "rappel",
            "est_reference",
            "est_actif",
            "est_deprecie",
            "fichier",
            "empreinte_sha256",
            "date_entrainement",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = ["id", "empreinte_sha256", "date_creation", "date_modification"]

    def validate_rmsecv(self, value):
        if value is not None and value < 0:
            raise serializers.ValidationError("rmsecv doit être positif ou nul.")
        return value

    def validate_fichier(self, fichier):
        # Extension et taille seulement : le contenu n'est jamais ouvert ni
        # interprété ici (voir modeles.models.Modele et modeles.services).
        extension = fichier.name.rsplit(".", 1)[-1].lower() if "." in fichier.name else ""
        if extension not in Modele.EXTENSIONS_AUTORISEES:
            raise serializers.ValidationError(
                "Extension non autorisée. Formats acceptés : "
                + ", ".join(Modele.EXTENSIONS_AUTORISEES)
                + "."
            )
        if fichier.size > Modele.TAILLE_MAX_OCTETS:
            raise serializers.ValidationError(
                "Le fichier dépasse la taille maximale autorisée "
                f"({Modele.TAILLE_MAX_OCTETS // (1024 * 1024)} Mo)."
            )
        return fichier


class HistoriqueUtilisationModeleSerializer(serializers.Serializer):
    nombre_resultats = serializers.IntegerField()
    derniere_utilisation = serializers.DateTimeField(allow_null=True)
