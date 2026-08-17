import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/network/connectivity_service.dart';
import 'package:olive_iq_app/features/authentification/data/datasources/auth_local_datasource.dart';
import 'package:olive_iq_app/features/authentification/data/datasources/auth_remote_datasource.dart';
import 'package:olive_iq_app/features/authentification/data/repositories/auth_repository_impl.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/raison_message_login.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late MockConnectivityService connectivityService;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(RaisonMessageLogin.aucune);
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();
    connectivityService = MockConnectivityService();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivityService: connectivityService,
    );
  });

  group('deconnecter', () {
    test('efface la session sans enregistrer de raison quand l\'appareil est en ligne', () async {
      when(() => connectivityService.estEnLigne()).thenAnswer((_) async => true);
      when(() => localDataSource.supprimerSession()).thenAnswer((_) async {});

      await repository.deconnecter();

      verifyNever(() => localDataSource.enregistrerRaisonMessageLogin(any()));
      verify(() => localDataSource.supprimerSession()).called(1);
    });

    test(
        'enregistre la raison "déconnexion hors ligne" avant d\'effacer la session quand hors ligne, '
        'pour que l\'écran de connexion prévienne l\'utilisateur', () async {
      when(() => connectivityService.estEnLigne()).thenAnswer((_) async => false);
      when(() => localDataSource.enregistrerRaisonMessageLogin(any())).thenAnswer((_) async {});
      when(() => localDataSource.supprimerSession()).thenAnswer((_) async {});

      await repository.deconnecter();

      verify(() => localDataSource
          .enregistrerRaisonMessageLogin(RaisonMessageLogin.deconnexionHorsLigne)).called(1);
      verify(() => localDataSource.supprimerSession()).called(1);
    });
  });
}
