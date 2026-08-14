from rest_framework import serializers

from modeles.models import TypeModele

from .models import PredictionModele, Resultat


class PredictionModeleSerializer(serializers.ModelSerializer):
    """Une ligne de prédiction, imbriquée dans ResultatSerializer. En
    écriture, seuls `modele` et la valeur pertinente à son type sont
    attendus ; `resultat` est fixé par resultats.services, jamais par le
    client. Les champs de confort (nom/type/grandeur du modèle) évitent une
    seconde requête pour afficher le bloc "Prédictions" côté mobile."""

    modele_nom = serializers.CharField(source="modele.nom", read_only=True)
    modele_version = serializers.CharField(source="modele.version", read_only=True)
    type_modele = serializers.CharField(source="modele.type_modele", read_only=True)
    grandeur_predite = serializers.CharField(source="modele.grandeur_predite", read_only=True)

    class Meta:
        model = PredictionModele
        fields = [
            "id",
            "modele",
            "modele_nom",
            "modele_version",
            "type_modele",
            "grandeur_predite",
            "valeur_numerique",
            "classe_predite",
            "score_confiance",
            "date_creation",
        ]
        read_only_fields = ["id", "date_creation"]

    def validate_modele(self, modele):
        if not modele.est_actif:
            raise serializers.ValidationError("Ce modèle n'est plus actif.")
        return modele

    def validate(self, donnees):
        modele = donnees.get("modele")
        if modele is None:
            return donnees
        if modele.type_modele == TypeModele.REGRESSION and donnees.get("valeur_numerique") is None:
            raise serializers.ValidationError(
                {"valeur_numerique": "Requis pour un modèle de régression."}
            )
        if modele.type_modele == TypeModele.CLASSIFICATION and not donnees.get("classe_predite"):
            raise serializers.ValidationError(
                {"classe_predite": "Requis pour un modèle de classification."}
            )
        return donnees


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
    producteur_echantillon = serializers.CharField(source="echantillon.producteur", read_only=True)
    region_echantillon = serializers.CharField(source="echantillon.region", read_only=True)
    # Utile côté admin (voir l'écran de détail d'analyse de l'espace admin,
    # qui affiche qui a réalisé l'analyse) — sans coût pour un utilisateur
    # standard, qui ne voit de toute façon que ses propres résultats.
    auteur_id = serializers.IntegerField(source="echantillon.utilisateur_id", read_only=True)
    auteur_nom = serializers.CharField(source="echantillon.utilisateur.nom", read_only=True)
    # En écriture : liste optionnelle des prédictions de chaque modèle
    # appliqué à ce scan (voir resultats.services.creer_resultat, qui les
    # crée et en dérive éventuellement acidite/conforme/modele_utilise).
    predictions = PredictionModeleSerializer(many=True, required=False)

    class Meta:
        model = Resultat
        fields = [
            "id",
            "echantillon",
            "numero_echantillon",
            "variete_echantillon",
            "origine_echantillon",
            "producteur_echantillon",
            "region_echantillon",
            "auteur_id",
            "auteur_nom",
            "numero_replicat",
            "modele_utilise",
            "acidite",
            "indice_peroxyde",
            "acidite_reference",
            "indice_peroxyde_reference",
            "authenticite_reference",
            "date_mesure_reference",
            "predictions",
            "date_calcul",
            "duree_analyse_secondes",
            "conforme",
            "commentaire",
            "valide_par",
            "date_creation",
            "date_modification",
        ]
        read_only_fields = [
            "numero_replicat",
            "date_calcul",
            "date_creation",
            "date_modification",
        ]

    def validate_acidite(self, value):
        if value < 0:
            raise serializers.ValidationError("L'acidité doit être positive ou nulle.")
        return value

    def validate_indice_peroxyde(self, value):
        if value < 0:
            raise serializers.ValidationError("L'indice de peroxyde doit être positif ou nul.")
        return value

    def validate_predictions(self, valeur):
        modeles_vus = [prediction["modele"].id for prediction in valeur]
        if len(modeles_vus) != len(set(modeles_vus)):
            raise serializers.ValidationError(
                "Un même modèle ne peut apparaître qu'une seule fois par résultat."
            )
        return valeur
