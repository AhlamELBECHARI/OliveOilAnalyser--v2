from django.contrib import admin

from .models import Alerte


@admin.register(Alerte)
class AlerteAdmin(admin.ModelAdmin):
    list_display = ("id", "type", "niveau_gravite", "est_resolue", "date_creation")
    list_filter = ("type", "niveau_gravite", "est_resolue")
    search_fields = ("message", "echantillon__numero")
