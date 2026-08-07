from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAdministrateur
from core.serializers import ErreurSerializer, MessageSerializer

from . import services
from .serializers import (
    ChangerMotDePasseSerializer,
    ConfigurationSerializer,
    ConfirmerResetMotDePasseSerializer,
    CreerAdministrateurSerializer,
    DemandeResetMotDePasseSerializer,
    LoginResponseSerializer,
    LoginSerializer,
    MonProfilSerializer,
    RegisterSerializer,
    SessionSerializer,
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


class MonProfilView(APIView):
    """GET/PATCH /api/utilisateurs/moi/ — un utilisateur consulte et modifie
    uniquement son propre profil ; role/is_staff/is_superuser ne sont jamais
    acceptés en entrée (voir MonProfilSerializer et services.modifier_profil)."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses=MonProfilSerializer)
    def get(self, request):
        return Response(MonProfilSerializer(request.user, context={"request": request}).data)

    @extend_schema(
        request=MonProfilSerializer,
        responses={200: MonProfilSerializer, 400: ErreurSerializer},
    )
    def patch(self, request):
        serializer = MonProfilSerializer(
            request.user, data=request.data, partial=True, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        utilisateur = services.modifier_profil(
            utilisateur=request.user, **serializer.validated_data
        )
        return Response(
            MonProfilSerializer(utilisateur, context={"request": request}).data
        )


class ChangerMotDePasseView(APIView):
    """POST /api/auth/changer-mot-de-passe/ — vérifie l'ancien mot de passe,
    définit le nouveau, et blackliste tous les refresh tokens en circulation
    (voir services.changer_mot_de_passe)."""

    permission_classes = [IsAuthenticated]

    @extend_schema(
        request=ChangerMotDePasseSerializer,
        responses={200: MessageSerializer, 400: ErreurSerializer},
    )
    def post(self, request):
        serializer = ChangerMotDePasseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.changer_mot_de_passe(utilisateur=request.user, **serializer.validated_data)
        return Response({"detail": "Mot de passe modifié avec succès."})


class SessionsView(APIView):
    """GET /api/auth/sessions/?jti_courant=<jti> — liste les sessions actives
    (refresh tokens émis, ni blacklistés ni expirés) de l'utilisateur. Le
    paramètre optionnel jti_courant (jti du refresh token du client) permet
    d'annoter la session courante sans que le serveur n'ait à la deviner."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses=SessionSerializer(many=True))
    def get(self, request):
        sessions = services.lister_sessions(
            utilisateur=request.user,
            jti_courant=request.query_params.get("jti_courant"),
        )
        return Response(SessionSerializer(sessions, many=True).data)


class SessionDetailView(APIView):
    """DELETE /api/auth/sessions/<id>/ — révoque (blackliste) une session."""

    permission_classes = [IsAuthenticated]

    @extend_schema(responses={204: None, 404: ErreurSerializer})
    def delete(self, request, session_id):
        services.revoquer_session(utilisateur=request.user, session_id=session_id)
        return Response(status=status.HTTP_204_NO_CONTENT)
