from django.contrib.auth.base_user import BaseUserManager


class UtilisateurManager(BaseUserManager):
    use_in_migrations = True

    def _creer_utilisateur(self, email, nom, password, **extra_fields):
        if not email:
            raise ValueError("L'email est obligatoire.")
        email = self.normalize_email(email).lower()
        utilisateur = self.model(email=email, nom=nom, **extra_fields)
        utilisateur.set_password(password)
        utilisateur.save(using=self._db)
        return utilisateur

    def create_user(self, email, nom, password=None, **extra_fields):
        extra_fields.setdefault("role", "utilisateur")
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._creer_utilisateur(email, nom, password, **extra_fields)

    def create_superuser(self, email, nom, password=None, **extra_fields):
        extra_fields["role"] = "administrateur"
        extra_fields["is_staff"] = True
        extra_fields["is_superuser"] = True
        return self._creer_utilisateur(email, nom, password, **extra_fields)
