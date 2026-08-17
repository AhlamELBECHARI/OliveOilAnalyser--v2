import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage_service.dart';
import 'auth_interceptor.dart';
import 'token_refresher.dart';

/// Construit l'instance Dio unique de l'application, avec l'URL de base
/// centralisée et l'interceptor d'authentification branché. Expose aussi le
/// [TokenRefresher] qu'il utilise, pour que SynchronisationService puisse
/// s'en servir afin de rafraîchir le token AVANT d'envoyer les données en
/// attente au retour du réseau (voir core/sync/synchronisation_service.dart),
/// sans dupliquer la logique de rafraîchissement.
class DioClient {
  final TokenStorageService tokenStorage;
  final void Function() onSessionExpiree;

  late final Dio dio;
  late final TokenRefresher tokenRefresher;

  DioClient({required this.tokenStorage, required this.onSessionExpiree}) {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.timeoutConnexion,
      receiveTimeout: AppConfig.timeoutReponse,
      contentType: 'application/json',
    ));
    tokenRefresher = TokenRefresher(tokenStorage: tokenStorage);
    dio.interceptors.add(AuthInterceptor(
      tokenStorage: tokenStorage,
      onSessionExpiree: onSessionExpiree,
      tokenRefresher: tokenRefresher,
    ));
  }
}
