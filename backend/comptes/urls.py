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
]
