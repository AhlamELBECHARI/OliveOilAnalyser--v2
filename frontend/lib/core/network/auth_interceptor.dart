import 'package:dio/dio.dart';

import '../storage/token_storage_service.dart';
import 'token_refresher.dart';

/// Endpoints publics qui ne doivent jamais recevoir le header Authorization
/// ni déclencher de tentative de rafraîchissement sur 401.
const _endpointsPublics = [
  '/auth/login/',
  '/auth/register/',
  '/auth/refresh/',
  '/auth/reset-password/',
];

/// Interceptor Dio qui :
/// 1. injecte automatiquement `Authorization: Bearer <access>` sur les
///    requêtes authentifiées ;
/// 2. sur une 401, tente de rafraîchir l'access token via [TokenRefresher],
///    puis rejoue la requête originale ;
/// 3. ne déclenche [onSessionExpiree] (déconnexion) que si le serveur a
///    explicitement rejeté le refresh token. Un échec réseau pendant le
///    rafraîchissement ne déconnecte JAMAIS l'utilisateur hors ligne : la
///    requête d'origine échoue simplement, le token est conservé pour la
///    prochaine tentative une fois le réseau revenu.
class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final TokenRefresher _tokenRefresher;
  final void Function() onSessionExpiree;

  AuthInterceptor({
    required TokenStorageService tokenStorage,
    required this.onSessionExpiree,
    TokenRefresher? tokenRefresher,
  })  : _tokenStorage = tokenStorage,
        _tokenRefresher = tokenRefresher ?? TokenRefresher(tokenStorage: tokenStorage);

  bool _estEndpointPublic(String path) {
    return _endpointsPublics.any((e) => path.contains(e));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_estEndpointPublic(options.path)) {
      final accessToken = await _tokenStorage.lireAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requete = err.requestOptions;
    final estDeja401Rejouee = requete.extra['rejouee_apres_refresh'] == true;

    if (err.response?.statusCode != 401 ||
        _estEndpointPublic(requete.path) ||
        estDeja401Rejouee) {
      handler.next(err);
      return;
    }

    final resultat = await _tokenRefresher.rafraichir();

    if (resultat == ResultatRafraichissement.sessionInvalide) {
      onSessionExpiree();
      handler.next(err);
      return;
    }

    if (resultat == ResultatRafraichissement.echecReseau) {
      handler.next(err);
      return;
    }

    try {
      final nouvelAccessToken = await _tokenStorage.lireAccessToken();
      requete.headers['Authorization'] = 'Bearer $nouvelAccessToken';
      requete.extra['rejouee_apres_refresh'] = true;
      final dioOriginal = Dio(BaseOptions(baseUrl: requete.baseUrl));
      dioOriginal.interceptors.add(this);
      final reponse = await dioOriginal.fetch(requete);
      handler.resolve(reponse);
    } on DioException catch (erreurRejeu) {
      handler.next(erreurRejeu);
    }
  }
}
