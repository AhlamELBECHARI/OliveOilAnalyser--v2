from django.conf import settings
from django.db import models

from echantillons.models import Echantillon


class Alerte(models.Model):
    """
    Modèle créé pour ce jalon sans endpoints REST associés (hors périmètre
    des endpoints minimum demandés) : accessible pour l'instant uniquement
    via l'admin Django.
    """

    class Type(models.TextChoices):
        SEUIL_DEPASSE = "seuil_depasse", "Seuil dépassé"
        ERREUR_SYSTEME = "erreur_systeme", "Erreur système"
        QUALITE_DONNEES = "qualite_donnees", "Qualité des données"

    class NiveauGravite(models.TextChoices):
        INFO = "info", "Info"
        AVERTISSEMENT = "avertissement", "Avertissement"
        CRITIQUE = "critique", "Critique"

    echantillon = models.ForeignKey(
        Echantillon,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="alertes",
    )
    type = models.CharField(max_length=30, choices=Type.choices)
    message = models.TextField()
    niveau_gravite = models.CharField(
        max_length=20, choices=NiveauGravite.choices, db_index=True
    )
    date_creation = models.DateTimeField(auto_now_add=True, db_index=True)
    est_resolue = models.BooleanField(default=False, db_index=True)
    date_resolution = models.DateTimeField(null=True, blank=True)
    resolue_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="alertes_resolues",
    )
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "alertes_alerte"
        ordering = ["-date_creation"]
        verbose_name = "Alerte"
        verbose_name_plural = "Alertes"

    def __str__(self):
        return f"Alerte {self.pk} ({self.niveau_gravite})"
