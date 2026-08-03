import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage_service.dart';
import 'auth_interceptor.dart';

/// Construit l'instance Dio unique de l'application, avec l'URL de base
/// centralisée et l'interceptor d'authentification branché.
class DioClient {
  final TokenStorageService tokenStorage;
  final void Function() onSessionExpiree;

  late final Dio dio;

  DioClient({required this.tokenStorage, required this.onSessionExpiree}) {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.timeoutConnexion,
      receiveTimeout: AppConfig.timeoutReponse,
      contentType: 'application/json',
    ));
    dio.interceptors.add(AuthInterceptor(
      tokenStorage: tokenStorage,
      onSessionExpiree: onSessionExpiree,
    ));
  }
}
