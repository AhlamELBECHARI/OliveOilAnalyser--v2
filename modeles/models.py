from django.db import models


class Modele(models.Model):
    nom = models.CharField(max_length=150)
    version = models.CharField(max_length=30)
    algorithme = models.CharField(max_length=100)
    hyperparametres = models.JSONField(default=dict, blank=True)
    r2 = models.FloatField()
    rmsecv = models.FloatField()
    est_actif = models.BooleanField(default=True)
    est_deprecie = models.BooleanField(default=False)
    chemin_fichier = models.CharField(max_length=500, blank=True, default="")
    date_entrainement = models.DateTimeField(null=True, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "modeles_modele"
        ordering = ["-date_creation"]
        constraints = [
            models.UniqueConstraint(
                fields=["nom", "version"], name="modele_nom_version_unique"
            ),
            models.CheckConstraint(
                condition=models.Q(rmsecv__gte=0), name="modele_rmsecv_positif"
            ),
        ]
        verbose_name = "Modèle"
        verbose_name_plural = "Modèles"

    def __str__(self):
        return f"{self.nom} v{self.version}"
