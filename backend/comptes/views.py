from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAdministrateur

from . import services
from .serializers import (
    ConfigurationSerializer,
    ConfirmerResetMotDePasseSerializer,
    CreerAdministrateurSerializer,
    DemandeResetMotDePasseSerializer,
    LoginSerializer,
    RegisterSerializer,
    UtilisateurSerializer,
)


class RegisterView(APIView):
    """POST /api/auth/register/ — inscription publique, toujours role=utilisateur."""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        utilisateur = services.inscrire_utilisateur(**serializer.validated_data)
        return Response(UtilisateurSerializer(utilisateur).data, status=status.HTTP_201_CREATED)


class CreerAdministrateurView(APIView):
    """POST /api/utilisateurs/administrateurs/ — réservé aux administrateurs."""

    permission_classes = [IsAdministrateur]

    def post(self, request):
        serializer = CreerAdministrateurSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        utilisateur = services.creer_administrateur(**serializer.validated_data)
        return Response(UtilisateurSerializer(utilisateur).data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """POST /api/auth/login/"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        resultat = services.login(**serializer.validated_data)
        return Response(
            {
                "access": resultat["access"],
                "refresh": resultat["refresh"],
                "utilisateur": UtilisateurSerializer(resultat["utilisateur"]).data,
            }
        )


class DemandeResetMotDePasseView(APIView):
    """POST /api/auth/reset-password/ — envoie un token par email si le compte existe."""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = DemandeResetMotDePasseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.demander_reset_mot_de_passe(**serializer.validated_data)
        return Response(
            {"detail": "Si un compte existe avec cet email, un lien de réinitialisation a été envoyé."}
        )


class ConfirmerResetMotDePasseView(APIView):
    """POST /api/auth/reset-password/confirmer/"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ConfirmerResetMotDePasseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        donnees = serializer.validated_data
        services.confirmer_reset_mot_de_passe(
            token=donnees["token"], nouveau_mot_de_passe=donnees["nouveau_mot_de_passe"]
        )
        return Response({"detail": "Mot de passe réinitialisé avec succès."})


class UtilisateurListView(ListAPIView):
    """GET /api/utilisateurs/ — réservé aux administrateurs."""

    serializer_class = UtilisateurSerializer
    permission_classes = [IsAdministrateur]

    def get_queryset(self):
        return services.lister_utilisateurs()


class ConfigurationView(APIView):
    """GET/PUT /api/configuration/ — réservé aux administrateurs."""

    permission_classes = [IsAdministrateur]

    def get(self, request):
        configuration = services.obtenir_configuration()
        return Response(ConfigurationSerializer(configuration).data)

    def put(self, request):
        serializer = ConfigurationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        configuration = services.mettre_a_jour_configuration(
            utilisateur=request.user, **serializer.validated_data
        )
        return Response(ConfigurationSerializer(configuration).data)
