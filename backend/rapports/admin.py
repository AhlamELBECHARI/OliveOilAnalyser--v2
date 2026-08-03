from django.contrib import admin

from .models import Rapport


@admin.register(Rapport)
class RapportAdmin(admin.ModelAdmin):
    list_display = ("id", "echantillon", "format", "genere_par", "date_generation")
    list_filter = ("format",)
    search_fields = ("echantillon__numero", "genere_par__email")
