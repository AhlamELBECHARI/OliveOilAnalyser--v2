import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/network/token_refresher.dart';
import 'package:olive_iq_app/core/storage/token_storage_service.dart';

class MockTokenStorageService extends Mock implements TokenStorageService {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockTokenStorageService tokenStorage;
  late MockDio dioRefresh;
  late TokenRefresher refresher;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/auth/refresh/'));
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    tokenStorage = MockTokenStorageService();
    dioRefresh = MockDio();
    refresher = TokenRefresher(tokenStorage: tokenStorage, dioRefresh: dioRefresh);
  });

  test('retourne sessionInvalide sans appel réseau quand aucun refresh token n\'est stocké', () async {
    when(() => tokenStorage.lireRefreshToken()).thenAnswer((_) async => null);

    final resultat = await refresher.rafraichir();

    expect(resultat, ResultatRafraichissement.sessionInvalide);
    verifyNever(() => dioRefresh.post(any(), data: any(named: 'data')));
  });

  test('retourne succes et persiste les nouveaux tokens quand le refresh réussit', () async {
    when(() => tokenStorage.lireRefreshToken()).thenAnswer((_) async => 'refresh-token');
    when(() => dioRefresh.post('/auth/refresh/', data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/auth/refresh/'),
        statusCode: 200,
        data: {'access': 'new-access', 'refresh': 'new-refresh'},
      ),
    );
    when(() => tokenStorage.enregistrerTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.enregistrerDerniereAuthentification(any())).thenAnswer((_) async {});

    final resultat = await refresher.rafraichir();

    expect(resultat, ResultatRafraichissement.succes);
    verify(() => tokenStorage.enregistrerTokens(accessToken: 'new-access', refreshToken: 'new-refresh'))
        .called(1);
    verify(() => tokenStorage.enregistrerDerniereAuthentification(any())).called(1);
  });

  test(
      "retourne echecReseau et NE SUPPRIME JAMAIS les tokens quand le serveur ne répond pas (hors ligne) — "
      "c'est le bug corrigé : l'expiration de l'access token pendant une coupure réseau ne doit plus déconnecter",
      () async {
    when(() => tokenStorage.lireRefreshToken()).thenAnswer((_) async => 'refresh-token');
    when(() => dioRefresh.post('/auth/refresh/', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh/'),
        type: DioExceptionType.connectionError,
      ),
    );

    final resultat = await refresher.rafraichir();

    expect(resultat, ResultatRafraichissement.echecReseau);
    verifyNever(() => tokenStorage.supprimerTokens());
  });

  test('retourne sessionInvalide et efface les tokens quand le serveur rejette explicitement le refresh token',
      () async {
    when(() => tokenStorage.lireRefreshToken()).thenAnswer((_) async => 'refresh-token');
    when(() => dioRefresh.post('/auth/refresh/', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh/'),
        response: Response(requestOptions: RequestOptions(path: '/auth/refresh/'), statusCode: 401),
      ),
    );
    when(() => tokenStorage.supprimerTokens()).thenAnswer((_) async {});

    final resultat = await refresher.rafraichir();

    expect(resultat, ResultatRafraichissement.sessionInvalide);
    verify(() => tokenStorage.supprimerTokens()).called(1);
  });
}
