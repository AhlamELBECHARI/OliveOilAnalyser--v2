from rest_framework import serializers


class MetriqueAvecVariationSerializer(serializers.Serializer):
    valeur = serializers.IntegerField()
    variation_pourcentage = serializers.FloatField(allow_null=True)


class EchantillonsTotauxSerializer(serializers.Serializer):
    valeur = serializers.IntegerField()
    ajouts_ce_mois = serializers.IntegerField()


class TempsMoyenSerializer(serializers.Serializer):
    valeur = serializers.FloatField(allow_null=True)
    variation_pourcentage = serializers.FloatField(allow_null=True)


class PointSerieSerializer(serializers.Serializer):
    date = serializers.DateField()
    nombre_analyses = serializers.IntegerField()


class RepartitionQualiteSerializer(serializers.Serializer):
    categorie = serializers.CharField()
    libelle = serializers.CharField()
    effectif = serializers.IntegerField()
    pourcentage = serializers.FloatField()


class AnalyseRecenteSerializer(serializers.Serializer):
    resultat_id = serializers.UUIDField()
    numero = serializers.CharField()
    origine = serializers.CharField()
    variete = serializers.CharField()
    heure = serializers.CharField()
    categorie = serializers.CharField()


class StatistiquesDashboardSerializer(serializers.Serializer):
    nom_utilisateur = serializers.CharField()
    analyses_ce_mois = MetriqueAvecVariationSerializer()
    echantillons_totaux = EchantillonsTotauxSerializer()
    analyses_aujourd_hui = MetriqueAvecVariationSerializer()
    temps_moyen_par_analyse_minutes = TempsMoyenSerializer()
    serie_7_jours = PointSerieSerializer(many=True)
    repartition_qualite = RepartitionQualiteSerializer(many=True)
    analyses_recentes = AnalyseRecenteSerializer(many=True)
