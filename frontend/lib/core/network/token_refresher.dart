import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage_service.dart';

/// Résultat d'une tentative de rafraîchissement du token — distingue
/// explicitement un refresh token réellement invalide (le serveur a répondu,
/// la session est morte) d'une simple absence de réseau (rien ne prouve que
/// la session soit invalide, elle doit rester utilisable hors ligne).
enum ResultatRafraichissement { succes, sessionInvalide, echecReseau }

/// Rafraîchit l'access token via /api/auth/refresh/. Partagé par
/// [AuthInterceptor] (rafraîchissement réactif sur 401) et
/// SynchronisationService (rafraîchissement proactif au retour réseau,
/// avant tout envoi de données en attente) : une seule implémentation de la
/// décision "réseau vs session invalide", jamais dupliquée.
class TokenRefresher {
  final TokenStorageService _tokenStorage;
  final Dio _dioRefresh;

  Completer<ResultatRafraichissement>? _rafraichissementEnCours;

  TokenRefresher({
    required TokenStorageService tokenStorage,
    Dio? dioRefresh,
  })  : // ignore: prefer_initializing_formals
        _tokenStorage = tokenStorage,
        _dioRefresh = dioRefresh ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.timeoutConnexion,
              receiveTimeout: AppConfig.timeoutReponse,
            ));

  /// Mutualise les rafraîchissements concurrents : une seule requête en vol
  /// à la fois, les autres attendent son résultat.
  Future<ResultatRafraichissement> rafraichir() async {
    if (_rafraichissementEnCours != null) {
      return _rafraichissementEnCours!.future;
    }

    final completer = Completer<ResultatRafraichissement>();
    _rafraichissementEnCours = completer;

    try {
      final refreshToken = await _tokenStorage.lireRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(ResultatRafraichissement.sessionInvalide);
        return ResultatRafraichissement.sessionInvalide;
      }

      final reponse = await _dioRefresh.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final nouvelAccess = reponse.data['access'] as String?;
      final nouveauRefresh = reponse.data['refresh'] as String?;

      if (nouvelAccess == null) {
        completer.complete(ResultatRafraichissement.sessionInvalide);
        return ResultatRafraichissement.sessionInvalide;
      }

      if (nouveauRefresh != null) {
        await _tokenStorage.enregistrerTokens(
          accessToken: nouvelAccess,
          refreshToken: nouveauRefresh,
        );
      } else {
        await _tokenStorage.enregistrerAccessToken(nouvelAccess);
      }
      await _tokenStorage.enregistrerDerniereAuthentification(DateTime.now());

      completer.complete(ResultatRafraichissement.succes);
      return ResultatRafraichissement.succes;
    } on DioException catch (e) {
      // Pas de réponse du serveur (timeout, pas de réseau...) : on ne peut
      // rien affirmer sur la validité de la session, elle reste donc
      // utilisable hors ligne — voir core/network/auth_interceptor.dart.
      // Une réponse (401/400...) signifie que le serveur a explicitement
      // rejeté le refresh token : la session est bien morte.
      if (e.response == null) {
        completer.complete(ResultatRafraichissement.echecReseau);
        return ResultatRafraichissement.echecReseau;
      }
      await _tokenStorage.supprimerTokens();
      completer.complete(ResultatRafraichissement.sessionInvalide);
      return ResultatRafraichissement.sessionInvalide;
    } catch (_) {
      completer.complete(ResultatRafraichissement.echecReseau);
      return ResultatRafraichissement.echecReseau;
    } finally {
      _rafraichissementEnCours = null;
    }
  }
}
