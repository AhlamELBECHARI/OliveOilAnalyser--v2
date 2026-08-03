import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage_service.dart';

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
/// 2. sur une 401, tente une seule fois de rafraîchir l'access token via
///    /api/auth/refresh/, puis rejoue la requête originale ;
/// 3. mutualise les rafraîchissements concurrents (une seule requête de
///    refresh en vol à la fois, les autres attendent son résultat).
class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final Dio _dioRefresh;
  final void Function() onSessionExpiree;

  Completer<String?>? _refreshEnCours;

  AuthInterceptor({
    required TokenStorageService tokenStorage,
    required this.onSessionExpiree,
    Dio? dioRefresh,
  })  : // ignore: prefer_initializing_formals
        _tokenStorage = tokenStorage,
        _dioRefresh = dioRefresh ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.timeoutConnexion,
              receiveTimeout: AppConfig.timeoutReponse,
            ));

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

    final nouvelAccessToken = await _rafraichirToken();
    if (nouvelAccessToken == null) {
      onSessionExpiree();
      handler.next(err);
      return;
    }

    try {
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

  /// Rafraîchit l'access token. Si un rafraîchissement est déjà en cours
  /// (requêtes concurrentes), attend son résultat plutôt que d'en démarrer
  /// un second.
  Future<String?> _rafraichirToken() async {
    if (_refreshEnCours != null) {
      return _refreshEnCours!.future;
    }

    final completer = Completer<String?>();
    _refreshEnCours = completer;

    try {
      final refreshToken = await _tokenStorage.lireRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      final reponse = await _dioRefresh.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final nouvelAccess = reponse.data['access'] as String?;
      final nouveauRefresh = reponse.data['refresh'] as String?;

      if (nouvelAccess == null) {
        completer.complete(null);
        return null;
      }

      if (nouveauRefresh != null) {
        await _tokenStorage.enregistrerTokens(
          accessToken: nouvelAccess,
          refreshToken: nouveauRefresh,
        );
      } else {
        await _tokenStorage.enregistrerAccessToken(nouvelAccess);
      }

      completer.complete(nouvelAccess);
      return nouvelAccess;
    } catch (_) {
      await _tokenStorage.supprimerTokens();
      completer.complete(null);
      return null;
    } finally {
      _refreshEnCours = null;
    }
  }
}
