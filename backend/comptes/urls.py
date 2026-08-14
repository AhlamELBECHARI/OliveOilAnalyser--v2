from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from . import views

urlpatterns = [
    path("auth/register/", views.RegisterView.as_view(), name="auth-register"),
    path("auth/login/", views.LoginView.as_view(), name="auth-login"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="auth-refresh"),
    path(
        "auth/reset-password/",
        views.DemandeResetMotDePasseView.as_view(),
        name="auth-reset-password",
    ),
    path(
        "auth/reset-password/verify/",
        views.VerifierCodeResetView.as_view(),
        name="auth-reset-password-verify",
    ),
    path(
        "auth/reset-password/confirm/",
        views.ConfirmerResetMotDePasseView.as_view(),
        name="auth-reset-password-confirm",
    ),
    path(
        "auth/changer-mot-de-passe/",
        views.ChangerMotDePasseView.as_view(),
        name="auth-changer-mot-de-passe",
    ),
    path("auth/sessions/", views.SessionsView.as_view(), name="auth-sessions"),
    path(
        "auth/sessions/<int:session_id>/",
        views.SessionDetailView.as_view(),
        name="auth-session-detail",
    ),
    path("utilisateurs/", views.UtilisateurListView.as_view(), name="utilisateurs-liste"),
    path("utilisateurs/moi/", views.MonProfilView.as_view(), name="utilisateurs-moi"),
    path(
        "utilisateurs/administrateurs/",
        views.CreerAdministrateurView.as_view(),
        name="utilisateurs-creer-administrateur",
    ),
    path("configuration/", views.ConfigurationView.as_view(), name="configuration"),
    # --- Espace admin ---
    path(
        "admin/utilisateurs/",
        views.AdminUtilisateurListView.as_view(),
        name="admin-utilisateurs-liste",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/",
        views.AdminUtilisateurDetailView.as_view(),
        name="admin-utilisateurs-detail",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/role/",
        views.AdminChangerRoleView.as_view(),
        name="admin-utilisateurs-role",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/activation/",
        views.AdminActivationView.as_view(),
        name="admin-utilisateurs-activation",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/deverrouiller/",
        views.AdminDeverrouillerView.as_view(),
        name="admin-utilisateurs-deverrouiller",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/reset-mot-de-passe/",
        views.AdminResetMotDePasseView.as_view(),
        name="admin-utilisateurs-reset-mot-de-passe",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/sessions/",
        views.AdminSessionsView.as_view(),
        name="admin-utilisateurs-sessions",
    ),
    path(
        "admin/utilisateurs/<int:utilisateur_id>/sessions/<int:session_id>/",
        views.AdminSessionDetailView.as_view(),
        name="admin-utilisateurs-session-detail",
    ),
]
