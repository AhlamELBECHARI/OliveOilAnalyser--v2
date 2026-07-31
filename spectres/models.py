import uuid

from django.db import models

from echantillons.models import Echantillon


class Spectre(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon = models.ForeignKey(
        Echantillon, on_delete=models.CASCADE, related_name="spectres"
    )
    valeurs_x = models.JSONField()
    valeurs_y = models.JSONField()
    nombre_series = models.PositiveIntegerField()
    date_acquisition = models.DateTimeField(db_index=True)
    checksum = models.CharField(max_length=64, blank=True, default="")
    taille_donnees = models.PositiveIntegerField(null=True, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "spectres_spectre"
        ordering = ["-date_acquisition"]
        verbose_name = "Spectre"
        verbose_name_plural = "Spectres"

    def __str__(self):
        return f"Spectre {self.id} ({self.echantillon.numero})"
