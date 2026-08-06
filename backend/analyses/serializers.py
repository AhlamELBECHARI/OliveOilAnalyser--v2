from rest_framework import serializers

from rapports.models import Rapport


class ResultatHistoriqueSerializer(serializers.Serializer):
    """Sérialise un queryset de Resultat annoté avec `categorie` (voir
    core.qualite.annotation_categorie). Serializer simple, pas un
    ModelSerializer : la source est un queryset annoté/filtré par
    analyses.services, pas directement le modèle."""

    id = serializers.UUIDField()
    numero_echantillon = serializers.CharField(source="echantillon.numero")
    producteur_echantillon = serializers.CharField(source="echantillon.producteur")
    variete_echantillon = serializers.CharField(source="echantillon.variete")
    region_echantillon = serializers.CharField(source="echantillon.region")
    origine_echantillon = serializers.CharField(source="echantillon.origine")
    acidite = serializers.DecimalField(max_digits=6, decimal_places=3)
    indice_peroxyde = serializers.DecimalField(max_digits=6, decimal_places=3)
    date_calcul = serializers.DateTimeField()
    conforme = serializers.BooleanField()
    categorie = serializers.CharField()


class PointSerieSerializer(serializers.Serializer):
    date = serializers.CharField()
    valeur = serializers.FloatField(allow_null=True)


class IndicateurAvecSerieSerializer(serializers.Serializer):
    valeur = serializers.FloatField(allow_null=True)
    variation_pourcentage = serializers.FloatField(allow_null=True)
    serie = PointSerieSerializer(many=True)


class RepartitionQualiteItemSerializer(serializers.Serializer):
    categorie = serializers.CharField()
    libelle = serializers.CharField()
    effectif = serializers.IntegerField()
    pourcentage = serializers.FloatField()


class IndicateurEntierSerializer(serializers.Serializer):
    valeur = serializers.IntegerField()
    variation_pourcentage = serializers.FloatField(allow_null=True)


class ApercuHistoriqueSerializer(serializers.Serializer):
    total_analyses = serializers.IntegerField()
    repartition_qualite = RepartitionQualiteItemSerializer(many=True)
    ce_mois = IndicateurEntierSerializer()


class StatistiquesRapidesSerializer(serializers.Serializer):
    apercu = ApercuHistoriqueSerializer()
    tendance_acidite_moyenne = IndicateurAvecSerieSerializer()
    meilleure_qualite = IndicateurAvecSerieSerializer()
    plus_forte_acidite = IndicateurAvecSerieSerializer()
    analyses_par_jour = IndicateurAvecSerieSerializer()


class ExportDemandeSerializer(serializers.Serializer):
    format = serializers.ChoiceField(choices=Rapport.Format.choices)


class RapportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rapport
        fields = ["id", "format", "date_generation", "chemin_fichier", "taille"]
        read_only_fields = fields
