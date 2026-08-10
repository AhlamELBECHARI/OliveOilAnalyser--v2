from django.urls import reverse
from rest_framework import serializers

from core.qualite import LIBELLES_CATEGORIE
from rapports.models import Rapport

from .export import CONTENU_CHOICES, CONTENU_RESULTATS


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
    """Corps de POST /api/analyses/export/. Deux modes de sélection,
    exclusifs côté UI mais non forcés ici : si `identifiants` est fourni, il
    prime sur les filtres (mêmes filtres que GET /api/analyses/historique/,
    réutilisés tels quels pour que « toutes les analyses correspondant aux
    filtres actifs » corresponde exactement à ce que l'écran affiche déjà)."""

    contenu = serializers.ChoiceField(choices=CONTENU_CHOICES)
    format = serializers.ChoiceField(choices=Rapport.Format.choices)
    identifiants = serializers.ListField(
        child=serializers.UUIDField(), required=False, allow_empty=False
    )
    recherche = serializers.CharField(required=False, allow_blank=True)
    qualite = serializers.ChoiceField(choices=list(LIBELLES_CATEGORIE.keys()), required=False)
    variete = serializers.CharField(required=False, allow_blank=True)
    region = serializers.CharField(required=False, allow_blank=True)
    date_debut = serializers.DateField(required=False)
    date_fin = serializers.DateField(required=False)

    def validate(self, donnees):
        # Le PDF est un rapport de lecture pour des résultats ; un tableau de
        # ~1000 points de spectre par échantillon n'a pas de sens en PDF.
        if donnees["format"] == Rapport.Format.PDF and donnees["contenu"] != CONTENU_RESULTATS:
            raise serializers.ValidationError(
                "Le format PDF n'est disponible que pour l'export des résultats."
            )
        return donnees


class RapportSerializer(serializers.ModelSerializer):
    url_telechargement = serializers.SerializerMethodField()

    class Meta:
        model = Rapport
        fields = ["id", "format", "date_generation", "chemin_fichier", "taille", "url_telechargement"]
        read_only_fields = fields

    def get_url_telechargement(self, rapport) -> str | None:
        if not rapport.chemin_fichier:
            return None
        chemin = reverse("rapport-telecharger", kwargs={"pk": rapport.pk})
        request = self.context.get("request")
        return request.build_absolute_uri(chemin) if request else chemin
