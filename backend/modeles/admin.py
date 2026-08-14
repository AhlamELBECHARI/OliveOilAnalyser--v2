from django.contrib import admin

from .models import Modele


@admin.register(Modele)
class ModeleAdmin(admin.ModelAdmin):
    list_display = (
        "nom",
        "version",
        "type_modele",
        "grandeur_predite",
        "r2",
        "rmsecv",
        "est_reference",
        "est_actif",
        "est_deprecie",
    )
    list_filter = ("type_modele", "grandeur_predite", "est_reference", "est_actif", "est_deprecie")
    search_fields = ("nom", "version")
