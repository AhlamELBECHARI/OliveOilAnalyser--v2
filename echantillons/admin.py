from django.contrib import admin

from .models import Echantillon


@admin.register(Echantillon)
class EchantillonAdmin(admin.ModelAdmin):
    list_display = ("numero", "utilisateur", "date_analyse", "date_creation")
    list_filter = ("date_analyse",)
    search_fields = ("numero", "utilisateur__email")
