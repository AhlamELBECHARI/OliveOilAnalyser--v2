from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .forms import UtilisateurChangeForm, UtilisateurCreationForm
from .models import Configuration, Utilisateur


@admin.register(Utilisateur)
class UtilisateurAdmin(DjangoUserAdmin):
    model = Utilisateur
    form = UtilisateurChangeForm
    add_form = UtilisateurCreationForm

    list_display = ("email", "nom", "role", "est_actif", "is_staff", "date_creation")
    list_filter = ("role", "est_actif", "is_staff")
    search_fields = ("email", "nom")
    ordering = ("-date_creation",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Informations personnelles", {"fields": ("nom",)}),
        ("Rôle et statut", {"fields": ("role", "est_actif", "is_staff", "is_superuser")}),
        ("Sécurité", {"fields": ("tentatives_echouees", "verrouille_jusqu_a")}),
        ("Dates", {"fields": ("last_login", "date_creation", "date_modification")}),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("email", "nom", "password1", "password2", "role"),
            },
        ),
    )
    readonly_fields = ("date_creation", "date_modification", "last_login")
    filter_horizontal = ()


@admin.register(Configuration)
class ConfigurationAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "seuil_conformite_acidite",
        "seuil_conformite_peroxyde",
        "notifications_actives",
        "est_actif",
        "date_modification",
    )
