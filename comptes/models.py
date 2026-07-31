from django.contrib.auth.base_user import AbstractBaseUser
from django.db import models

from .managers import UtilisateurManager


class Utilisateur(AbstractBaseUser):
    """
    Utilisateur custom, sans PermissionsMixin ni système de groupes/permissions
    Django : les permissions par rôle sont gérées par des classes DRF
    (core.permissions.IsAdministrateur), pas par le framework de permissions
    Django. is_staff/is_superuser existent uniquement pour que
    `createsuperuser` et l'admin Django fonctionnent.
    """

    class Role(models.TextChoices):
        UTILISATEUR = "utilisateur", "Utilisateur"
        ADMINISTRATEUR = "administrateur", "Administrateur"

    nom = models.CharField(max_length=150)
    email = models.EmailField(unique=True, db_index=True)
    role = models.CharField(
        max_length=20, choices=Role.choices, default=Role.UTILISATEUR, db_index=True
    )

    est_actif = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    tentatives_echouees = models.PositiveSmallIntegerField(default=0)
    verrouille_jusqu_a = models.DateTimeField(null=True, blank=True)

    token_reset_mot_de_passe_hash = models.CharField(max_length=64, blank=True, default="")
    token_reset_expiration = models.DateTimeField(null=True, blank=True)

    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    objects = UtilisateurManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["nom"]

    class Meta:
        db_table = "comptes_utilisateur"
        ordering = ["-date_creation"]
        verbose_name = "Utilisateur"
        verbose_name_plural = "Utilisateurs"

    def __str__(self):
        return self.email

    @property
    def is_active(self):
        return self.est_actif

    @is_active.setter
    def is_active(self, valeur):
        self.est_actif = valeur

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser


class Configuration(models.Model):
    """
    Table à une seule ligne (singleton géré par comptes.services), regroupant
    les réglages globaux de l'application.
    """

    notifications_actives = models.BooleanField(default=True)
    seuil_conformite_acidite = models.DecimalField(max_digits=6, decimal_places=3)
    seuil_conformite_peroxyde = models.DecimalField(max_digits=6, decimal_places=3)
    est_actif = models.BooleanField(default=True)
    modifie_par = models.ForeignKey(
        Utilisateur,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="configurations_modifiees",
    )
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "comptes_configuration"
        verbose_name = "Configuration"
        verbose_name_plural = "Configuration"

    def __str__(self):
        return f"Configuration #{self.pk}"
