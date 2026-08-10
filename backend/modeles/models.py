import uuid
from pathlib import Path

from django.db import models


def chemin_upload_modele(instance, nom_fichier):
    """Le fichier est renommé en UUID côté stockage — jamais le nom fourni
    par l'utilisateur — pour ne jamais faire confiance à un chemin ou une
    extension double (ex. "modele.pkl.exe") venant du client."""
    extension = Path(nom_fichier).suffix.lower()
    return f"modeles/{uuid.uuid4()}{extension}"


class Modele(models.Model):
    # Un modèle scikit-learn est généralement sérialisé en pickle/joblib, dont
    # le chargement peut exécuter du code arbitraire. Le backend ne
    # désérialise donc JAMAIS ce fichier (voir modeles.services) : il se
    # contente de vérifier l'extension, la taille, de le stocker tel quel et
    # d'enregistrer son empreinte SHA-256 pour vérification d'intégrité
    # ultérieure. Le chargement effectif relève d'un processus séparé et
    # contrôlé, hors de cette API — voir README.
    EXTENSIONS_AUTORISEES = ["pkl", "pickle", "joblib"]
    TAILLE_MAX_OCTETS = 50 * 1024 * 1024  # 50 Mo

    nom = models.CharField(max_length=150)
    version = models.CharField(max_length=30)
    algorithme = models.CharField(max_length=100)
    hyperparametres = models.JSONField(default=dict, blank=True)
    r2 = models.FloatField()
    rmsecv = models.FloatField()
    est_actif = models.BooleanField(default=True)
    est_deprecie = models.BooleanField(default=False)
    fichier = models.FileField(upload_to=chemin_upload_modele, null=True, blank=True)
    empreinte_sha256 = models.CharField(max_length=64, blank=True, default="")
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
