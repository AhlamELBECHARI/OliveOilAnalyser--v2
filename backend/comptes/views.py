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
    ActivationSerializer,
    ChangerMotDePasseSerializer,
    ChangerRoleSerializer,
    ConfigurationSerializer,
    ConfirmerResetMotDePasseSerializer,
    CreerAdministrateurSerializer,
    CreerUtilisateurAdminSerializer,
    DemandeResetMotDePasseSerializer,
    LoginResponseSerializer,
    LoginSerializer,
    MonProfilSerializer,
    RegisterSerializer,
    SessionSerializer,
    UtilisateurAdminSerializer,
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
    """GET /api/configuration/ — consultable par tout utilisateur authentifié
    (les seuils qu'elle porte, ex. catégorie EVOO/VOO/Lampante, sont utilisés
    par l'app mobile bien au-delà de l'écran d'administration). PUT réservé
    aux administrateurs."""

    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated()]
        return [IsAdministrateur()]

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


# --- Espace admin : gestion des utilisateurs --------------------------------


class AdminUtilisateurListView(APIView):
    """GET/POST /api/admin/utilisateurs/?recherche=&role=&actif=&verrouille=
    — liste (recherche nom/email, filtres rôle/actif/verrouillé) et création
    de compte (utilisateur ou administrateur)."""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses=UtilisateurAdminSerializer(many=True))
    def get(self, request):
        from core.pagination import PaginationStandard

        parametres = request.query_params
        actif = parametres.get("actif")
        verrouille = parametres.get("verrouille")
        queryset = services.lister_utilisateurs_admin(
            recherche=parametres.get("recherche"),
            role=parametres.get("role"),
            actif=None if actif is None else actif == "true",
            verrouille=None if verrouille is None else verrouille == "true",
        )
        paginateur = PaginationStandard()
        page = paginateur.paginate_queryset(queryset, request)
        serializer = UtilisateurAdminSerializer(page, many=True)
        return paginateur.get_paginated_response(serializer.data)

    @extend_schema(
        request=CreerUtilisateurAdminSerializer,
        responses={201: UtilisateurAdminSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def post(self, request):
        serializer = CreerUtilisateurAdminSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        donnees = dict(serializer.validated_data)
        donnees.pop("password2")
        utilisateur = services.creer_utilisateur_admin(acteur=request.user, **donnees)
        return Response(
            UtilisateurAdminSerializer(utilisateur).data, status=status.HTTP_201_CREATED
        )


class AdminUtilisateurDetailView(APIView):
    """GET /api/admin/utilisateurs/<id>/"""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses={200: UtilisateurAdminSerializer, 404: ErreurSerializer})
    def get(self, request, utilisateur_id):
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        return Response(UtilisateurAdminSerializer(cible).data)


class AdminChangerRoleView(APIView):
    """PATCH /api/admin/utilisateurs/<id>/role/ — voir les garde-fous dans
    comptes.services.changer_role_admin (auto-modification, dernier
    administrateur)."""

    permission_classes = [IsAdministrateur]

    @extend_schema(
        request=ChangerRoleSerializer,
        responses={200: UtilisateurAdminSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def patch(self, request, utilisateur_id):
        serializer = ChangerRoleSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        cible = services.changer_role_admin(
            acteur=request.user, cible=cible, nouveau_role=serializer.validated_data["role"]
        )
        return Response(UtilisateurAdminSerializer(cible).data)


class AdminActivationView(APIView):
    """PATCH /api/admin/utilisateurs/<id>/activation/ — désactivation
    LOGIQUE uniquement (jamais de suppression, voir comptes.services.
    definir_activation_admin) ; garde-fous : auto-désactivation, dernier
    administrateur."""

    permission_classes = [IsAdministrateur]

    @extend_schema(
        request=ActivationSerializer,
        responses={200: UtilisateurAdminSerializer, 400: ErreurSerializer, 403: ErreurSerializer},
    )
    def patch(self, request, utilisateur_id):
        serializer = ActivationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        cible = services.definir_activation_admin(
            acteur=request.user, cible=cible, actif=serializer.validated_data["actif"]
        )
        return Response(UtilisateurAdminSerializer(cible).data)


class AdminDeverrouillerView(APIView):
    """POST /api/admin/utilisateurs/<id>/deverrouiller/"""

    permission_classes = [IsAdministrateur]

    @extend_schema(request=None, responses={200: UtilisateurAdminSerializer, 404: ErreurSerializer})
    def post(self, request, utilisateur_id):
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        cible = services.deverrouiller_compte_admin(acteur=request.user, cible=cible)
        return Response(UtilisateurAdminSerializer(cible).data)


class AdminResetMotDePasseView(APIView):
    """POST /api/admin/utilisateurs/<id>/reset-mot-de-passe/ — déclenche
    l'envoi du code de réinitialisation à CET utilisateur (même mécanisme
    que la demande self-service, voir comptes.services.demander_reset_mot_de_passe)."""

    permission_classes = [IsAdministrateur]

    @extend_schema(request=None, responses={200: MessageSerializer, 404: ErreurSerializer})
    def post(self, request, utilisateur_id):
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        services.declencher_reset_mot_de_passe_admin(acteur=request.user, cible=cible)
        return Response({"detail": "Code de réinitialisation envoyé."})


class AdminSessionsView(APIView):
    """GET /api/admin/utilisateurs/<id>/sessions/"""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses=SessionSerializer(many=True))
    def get(self, request, utilisateur_id):
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        sessions = services.lister_sessions_admin(cible=cible)
        return Response(SessionSerializer(sessions, many=True).data)


class AdminSessionDetailView(APIView):
    """DELETE /api/admin/utilisateurs/<id>/sessions/<session_id>/ — révoque
    la session d'un autre utilisateur."""

    permission_classes = [IsAdministrateur]

    @extend_schema(responses={204: None, 404: ErreurSerializer})
    def delete(self, request, utilisateur_id, session_id):
        cible = services.obtenir_utilisateur_admin(utilisateur_id)
        services.revoquer_session_admin(cible=cible, session_id=session_id)
        return Response(status=status.HTTP_204_NO_CONTENT)
