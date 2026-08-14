import uuid

from django.conf import settings
from django.db import models

from echantillons.models import Echantillon
from modeles.models import Modele


class ClasseAuthenticite(models.TextChoices):
    PURE = "pure", "Pure"
    MELANGEE = "melangee", "Mélangée"


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
    # Durée réelle de traitement de l'analyse, en secondes — nulle tant que
    # le pipeline qui la mesure n'a pas encore tourné pour ce résultat.
    # Utilisée par dashboard.services pour le « temps moyen par analyse »
    # (moyenne SQL, jamais une valeur fixe).
    duree_analyse_secondes = models.PositiveIntegerField(null=True, blank=True)
    conforme = models.BooleanField()
    commentaire = models.TextField(blank=True, default="")
    valide_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="resultats_valides",
    )
    # Rang du scan pour cet échantillon (réplicats) — calculé par
    # resultats.services.creer_resultat, jamais fourni par le client.
    numero_replicat = models.PositiveSmallIntegerField(default=1)
    # Valeurs mesurées a posteriori au laboratoire, saisies manuellement pour
    # comparer prédiction et vérité terrain — absentes tant que la mesure
    # labo n'a pas encore été faite.
    acidite_reference = models.DecimalField(
        max_digits=6, decimal_places=3, null=True, blank=True
    )
    indice_peroxyde_reference = models.DecimalField(
        max_digits=6, decimal_places=3, null=True, blank=True
    )
    authenticite_reference = models.CharField(
        max_length=20, choices=ClasseAuthenticite.choices, blank=True, default=""
    )
    date_mesure_reference = models.DateField(null=True, blank=True)
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


class PredictionModele(models.Model):
    """Une prédiction d'un modèle donné pour un Resultat donné. Un scan est
    évalué par plusieurs modèles simultanément (régression et
    classification) — voir resultats.services.creer_resultat, qui dérive les
    champs de synthèse de Resultat (acidité retenue, conformité) à partir de
    la prédiction du modèle marqué `est_reference`."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    resultat = models.ForeignKey(
        Resultat, on_delete=models.CASCADE, related_name="predictions"
    )
    modele = models.ForeignKey(
        Modele, on_delete=models.PROTECT, related_name="predictions"
    )
    # Régression : valeur continue prédite (ex. acidité en %).
    valeur_numerique = models.DecimalField(
        max_digits=8, decimal_places=4, null=True, blank=True
    )
    # Classification : classe prédite + score de confiance associé.
    classe_predite = models.CharField(
        max_length=20, choices=ClasseAuthenticite.choices, blank=True, default=""
    )
    score_confiance = models.FloatField(null=True, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "resultats_prediction_modele"
        ordering = ["-date_creation"]
        constraints = [
            models.UniqueConstraint(
                fields=["resultat", "modele"], name="prediction_unique_par_resultat_modele"
            )
        ]
        verbose_name = "Prédiction de modèle"
        verbose_name_plural = "Prédictions de modèles"

    def __str__(self):
        return f"Prédiction {self.modele} → {self.resultat_id}"
