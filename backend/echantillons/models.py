import uuid

from django.conf import settings
from django.db import models


class Echantillon(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero = models.CharField(max_length=50, db_index=True)
    date_analyse = models.DateTimeField(db_index=True)
    utilisateur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="echantillons",
    )
    origine = models.CharField(max_length=255, blank=True, default="")
    notes = models.TextField(blank=True, default="")
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "echantillons_echantillon"
        ordering = ["-date_analyse"]
        constraints = [
            models.UniqueConstraint(
                fields=["utilisateur", "numero"],
                name="echantillon_numero_unique_par_utilisateur",
            )
        ]
        verbose_name = "Échantillon"
        verbose_name_plural = "Échantillons"

    def __str__(self):
        return self.numero
