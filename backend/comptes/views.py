from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAdministrateur
from core.serializers import ErreurSerializer, MessageSerializer

from . import services
from .serializers import (
    ConfigurationSerializer,
    ConfirmerResetMotDePasseSerializer,
    CreerAdministrateurSerializer,
    DemandeResetMotDePasseSerializer,
    LoginResponseSerializer,
    LoginSerializer,
    RegisterSerializer,
    UtilisateurSerializer,
    VerifierCodeResetSerializer,
)


class RegisterView(APIView):
    """POST /api/auth/register/ — inscription publique, toujours role=utilisateur."""

    permission_classes = [AllowAny]

    @extend_schema(
        request=RegisterSerializer,
        responses={201: UtilisateurSerializer, 400: ErreurSerializer},
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        utilisateur = services.inscrire_utilisateur(**serializer.validated_data)
        return Response(UtilisateurSerializer(utilisateur).data, status=status.HTTP_201_CREATED)


class CreerAdministrateurView(APIView):
    """POST /api/utilisateurs/administrateurs/ — réservé aux administrateurs."""

    permission_classes = [IsAdministrateur]

    @extend_schema(
        request=CreerAdministrateurSerializer,
        responses={201: UtilisateurSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def post(self, request):
        serializer = CreerAdministrateurSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        utilisateur = services.creer_administrateur(**serializer.validated_data)
        return Response(UtilisateurSerializer(utilisateur).data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """POST /api/auth/login/"""

    permission_classes = [AllowAny]

    @extend_schema(
        request=LoginSerializer,
        responses={200: LoginResponseSerializer, 401: ErreurSerializer},
    )
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
    """POST /api/auth/reset-password/ — envoie un code à 6 chiffres par email
    si le compte existe (réponse toujours identique, succès ou non, pour ne
    jamais révéler l'existence d'un compte)."""

    permission_classes = [AllowAny]

    @extend_schema(
        request=DemandeResetMotDePasseSerializer,
        responses={200: MessageSerializer, 429: ErreurSerializer},
    )
    def post(self, request):
        serializer = DemandeResetMotDePasseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.demander_reset_mot_de_passe(**serializer.validated_data)
        return Response(
            {"detail": "Si un compte existe avec cet email, un code a été envoyé."}
        )


class VerifierCodeResetView(APIView):
    """POST /api/auth/reset-password/verify/ — vérifie le code avant de
    laisser l'utilisateur saisir un nouveau mot de passe."""

    permission_classes = [AllowAny]

    @extend_schema(
        request=VerifierCodeResetSerializer,
        responses={200: MessageSerializer, 400: ErreurSerializer},
    )
    def post(self, request):
        serializer = VerifierCodeResetSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.verifier_code_reset(**serializer.validated_data)
        return Response({"detail": "Code valide."})


class ConfirmerResetMotDePasseView(APIView):
    """POST /api/auth/reset-password/confirm/"""

    permission_classes = [AllowAny]

    @extend_schema(
        request=ConfirmerResetMotDePasseSerializer,
        responses={200: MessageSerializer, 400: ErreurSerializer},
    )
    def post(self, request):
        serializer = ConfirmerResetMotDePasseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.confirmer_reset_mot_de_passe(**serializer.validated_data)
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

    @extend_schema(responses={200: ConfigurationSerializer, 403: ErreurSerializer})
    def get(self, request):
        configuration = services.obtenir_configuration()
        return Response(ConfigurationSerializer(configuration).data)

    @extend_schema(
        request=ConfigurationSerializer,
        responses={200: ConfigurationSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def put(self, request):
        serializer = ConfigurationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        configuration = services.mettre_a_jour_configuration(
            utilisateur=request.user, **serializer.validated_data
        )
        return Response(ConfigurationSerializer(configuration).data)
