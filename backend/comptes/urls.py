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
        "auth/reset-password/confirmer/",
        views.ConfirmerResetMotDePasseView.as_view(),
        name="auth-reset-password-confirmer",
    ),
    path("utilisateurs/", views.UtilisateurListView.as_view(), name="utilisateurs-liste"),
    path(
        "utilisateurs/administrateurs/",
        views.CreerAdministrateurView.as_view(),
        name="utilisateurs-creer-administrateur",
    ),
    path("configuration/", views.ConfigurationView.as_view(), name="configuration"),
]
