from django.contrib import admin

from .models import Spectre


@admin.register(Spectre)
class SpectreAdmin(admin.ModelAdmin):
    list_display = ("id", "echantillon", "nombre_series", "date_acquisition")
    search_fields = ("echantillon__numero", "checksum")
