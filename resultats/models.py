import uuid

from django.conf import settings
from django.db import models

from echantillons.models import Echantillon
from modeles.models import Modele


class Resultat(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon = models.ForeignKey(
        Echantillon, on_delete=models.PROTECT, related_name="resultats"
    )
    modele_utilise = models.ForeignKey(
        Modele, on_delete=models.PROTECT, related_name="resultats"
    )
    acidite = models.DecimalField(max_digits=6, decimal_places=3)
    indice_peroxyde = models.DecimalField(max_digits=6, decimal_places=3)
    date_calcul = models.DateTimeField(auto_now_add=True, db_index=True)
    conforme = models.BooleanField()
    commentaire = models.TextField(blank=True, default="")
    valide_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="resultats_valides",
    )
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "resultats_resultat"
        ordering = ["-date_calcul"]
        constraints = [
            models.CheckConstraint(
                condition=models.Q(acidite__gte=0) & models.Q(indice_peroxyde__gte=0),
                name="resultat_valeurs_positives",
            )
        ]
        verbose_name = "Résultat"
        verbose_name_plural = "Résultats"

    def __str__(self):
        return f"Résultat {self.id} ({self.echantillon.numero})"
