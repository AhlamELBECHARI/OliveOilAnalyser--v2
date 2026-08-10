import uuid

from django.conf import settings
from django.db import models

from echantillons.models import Echantillon


class Rapport(models.Model):
    """
    Créé par analyses.services.declencher_export lors d'un export. Seul
    endpoint REST dédié : GET /api/rapports/<id>/telecharger/ (voir
    rapports.views) pour récupérer le fichier généré ; le reste (recherche,
    filtrage) reste réservé à l'admin Django.
    """

    class Format(models.TextChoices):
        PDF = "PDF", "PDF"
        CSV = "CSV", "CSV"
        XLSX = "XLSX", "XLSX"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon = models.ForeignKey(
        Echantillon,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="rapports",
    )
    date_generation = models.DateTimeField(auto_now_add=True, db_index=True)
    format = models.CharField(max_length=10, choices=Format.choices)
    chemin_fichier = models.CharField(max_length=500)
    taille = models.PositiveIntegerField(null=True, blank=True)
    genere_par = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="rapports"
    )
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "rapports_rapport"
        ordering = ["-date_generation"]
        verbose_name = "Rapport"
        verbose_name_plural = "Rapports"

    def __str__(self):
        return f"Rapport {self.id} ({self.format})"
