from django.contrib import admin

from .models import PredictionModele, Resultat


@admin.register(Resultat)
class ResultatAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "echantillon",
        "numero_replicat",
        "modele_utilise",
        "acidite",
        "indice_peroxyde",
        "conforme",
        "date_calcul",
    )
    list_filter = ("conforme",)
    search_fields = ("echantillon__numero",)


@admin.register(PredictionModele)
class PredictionModeleAdmin(admin.ModelAdmin):
    list_display = ("resultat", "modele", "valeur_numerique", "classe_predite", "score_confiance")
    list_filter = ("modele__type_modele",)
    search_fields = ("resultat__echantillon__numero", "modele__nom")
