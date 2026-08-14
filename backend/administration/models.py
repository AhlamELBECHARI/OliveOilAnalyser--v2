import uuid

from django.conf import settings
from django.db import models


class JournalAudit(models.Model):
    """Historique des actions sensibles de l'application (connexions,
    créations/suppressions de comptes, changements de rôle, modifications de
    configuration, purges...). Écrite UNIQUEMENT depuis la couche services
    des apps concernées (voir administration.services.enregistrer_action) —
    jamais depuis une vue directement, pour que le journal reste fiable même
    si de nouveaux points d'entrée sont ajoutés plus tard."""

    class Action(models.TextChoices):
        CONNEXION_REUSSIE = "connexion_reussie", "Connexion réussie"
        CONNEXION_ECHOUEE = "connexion_echouee", "Connexion échouée"
        CREATION_COMPTE = "creation_compte", "Création de compte"
        CHANGEMENT_ROLE = "changement_role", "Changement de rôle"
        ACTIVATION_COMPTE = "activation_compte", "Activation de compte"
        DESACTIVATION_COMPTE = "desactivation_compte", "Désactivation de compte"
        DEVERROUILLAGE_COMPTE = "deverrouillage_compte", "Déverrouillage de compte"
        RESET_MOT_DE_PASSE_DECLENCHE = (
            "reset_mot_de_passe_declenche",
            "Réinitialisation de mot de passe déclenchée",
        )
        MODIFICATION_CONFIGURATION = "modification_configuration", "Modification de configuration"
        SUPPRESSION_MODELE = "suppression_modele", "Suppression de modèle"
        DEPRECIATION_MODELE = "depreciation_modele", "Dépréciation de modèle"
        REACTIVATION_MODELE = "reactivation_modele", "Réactivation de modèle"
        DEFINITION_MODELE_REFERENCE = (
            "definition_modele_reference",
            "Définition du modèle de référence",
        )
        PURGE_DONNEES = "purge_donnees", "Purge de données"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    action = models.CharField(max_length=40, choices=Action.choices, db_index=True)
    # SET_NULL (jamais CASCADE) : un compte désactivé/supprimé ne doit jamais
    # faire disparaître la trace de ce qu'il a fait.
    acteur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="actions_journal_audit",
    )
    cible_type = models.CharField(max_length=100, blank=True, default="")
    cible_id = models.CharField(max_length=64, blank=True, default="")
    details = models.JSONField(default=dict, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = "administration_journal_audit"
        ordering = ["-date_creation"]
        verbose_name = "Entrée de journal d'audit"
        verbose_name_plural = "Journal d'audit"

    def __str__(self):
        return f"{self.get_action_display()} — {self.date_creation:%Y-%m-%d %H:%M}"
