from django.contrib import admin

from .models import Resultat


@admin.register(Resultat)
class ResultatAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "echantillon",
        "modele_utilise",
        "acidite",
        "indice_peroxyde",
        "conforme",
        "date_calcul",
    )
    list_filter = ("conforme",)
    search_fields = ("echantillon__numero",)
