from django.contrib import admin

from .models import JournalAudit


@admin.register(JournalAudit)
class JournalAuditAdmin(admin.ModelAdmin):
    list_display = ("action", "acteur", "cible_type", "cible_id", "date_creation")
    list_filter = ("action",)
    search_fields = ("acteur__email", "cible_type", "cible_id")
    readonly_fields = [f.name for f in JournalAudit._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
