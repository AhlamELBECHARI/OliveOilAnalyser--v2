from django.contrib import admin

from .models import Modele


@admin.register(Modele)
class ModeleAdmin(admin.ModelAdmin):
    list_display = ("nom", "version", "algorithme", "r2", "rmsecv", "est_actif", "est_deprecie")
    list_filter = ("est_actif", "est_deprecie", "algorithme")
    search_fields = ("nom", "version")
