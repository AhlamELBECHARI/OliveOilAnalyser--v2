import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/app_navigator.dart';
import '../network/dio_client.dart';
import '../storage/token_storage_service.dart';
import '../../features/alertes/data/datasources/alertes_remote_datasource.dart';
import '../../features/alertes/data/repositories/alertes_repository_impl.dart';
import '../../features/alertes/domain/repositories/alertes_repository.dart';
import '../../features/alertes/domain/usecases/lister_alertes_usecase.dart';
import '../../features/authentification/data/datasources/auth_local_datasource.dart';
import '../../features/authentification/data/datasources/auth_remote_datasource.dart';
import '../../features/authentification/data/repositories/auth_repository_impl.dart';
import '../../features/authentification/domain/repositories/auth_repository.dart';
import '../../features/authentification/domain/usecases/confirmer_reset_mot_de_passe_usecase.dart';
import '../../features/authentification/domain/usecases/demander_reset_mot_de_passe_usecase.dart';
import '../../features/authentification/domain/usecases/get_session_locale_usecase.dart';
import '../../features/authentification/domain/usecases/login_usecase.dart';
import '../../features/authentification/domain/usecases/logout_usecase.dart';
import '../../features/authentification/domain/usecases/verifier_code_reset_usecase.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/data/repositories/etat_analyseur_repository_fake_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/etat_analyseur_repository.dart';
import '../../features/dashboard/domain/usecases/compter_alertes_non_resolues_usecase.dart';
import '../../features/dashboard/domain/usecases/obtenir_etat_analyseur_usecase.dart';
import '../../features/dashboard/domain/usecases/obtenir_statistiques_usecase.dart';
import '../../features/historique/data/datasources/historique_remote_datasource.dart';
import '../../features/historique/data/repositories/historique_repository_impl.dart';
import '../../features/historique/domain/repositories/historique_repository.dart';
import '../../features/historique/domain/usecases/lister_historique_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_resultat_usecase.dart';
import '../../features/modeles/data/datasources/modeles_remote_datasource.dart';
import '../../features/modeles/data/repositories/modeles_repository_impl.dart';
import '../../features/modeles/domain/repositories/modeles_repository.dart';
import '../../features/modeles/domain/usecases/lister_modeles_usecase.dart';
import '../../features/parametres/data/datasources/parametres_local_datasource.dart';
import '../../features/parametres/data/repositories/parametres_repository_impl.dart';
import '../../features/parametres/domain/repositories/parametres_repository.dart';
import '../../features/parametres/domain/usecases/definir_locale_usecase.dart';
import '../../features/parametres/domain/usecases/obtenir_locale_usecase.dart';

/// Conteneur d'injection de dépendances (get_it). C'est la seule "racine de
/// composition" de l'application : la Presentation ne connaît que les
/// UseCases exposés ici, jamais Dio ni le secure storage directement.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Core ---
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  sl.registerLazySingleton<AppNavigator>(() => AppNavigator());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<DioClient>(() => DioClient(
        tokenStorage: sl(),
        onSessionExpiree: () => sl<AppNavigator>().retourAuLogin(),
      ));
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // --- Feature: authentification ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(tokenStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => DemanderResetMotDePasseUseCase(sl()));
  sl.registerLazySingleton(() => VerifierCodeResetUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmerResetMotDePasseUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionLocaleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // --- Feature: dashboard ---
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  // Implémentation factice en attendant le module Bluetooth réel (voir
  // EtatAnalyseurRepository) : seul get_it doit être touché pour brancher la
  // vraie implémentation plus tard.
  sl.registerLazySingleton<EtatAnalyseurRepository>(
    () => EtatAnalyseurRepositoryFakeImpl(),
  );

  sl.registerLazySingleton(() => ObtenirStatistiquesUseCase(sl()));
  sl.registerLazySingleton(() => CompterAlertesNonResoluesUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirEtatAnalyseurUseCase(sl()));

  // --- Feature: parametres (langue) ---
  sl.registerLazySingleton<ParametresLocalDataSource>(
    () => ParametresLocalDataSourceImpl(preferences: sl()),
  );
  sl.registerLazySingleton<ParametresRepository>(
    () => ParametresRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => ObtenirLocaleUseCase(sl()));
  sl.registerLazySingleton(() => DefinirLocaleUseCase(sl()));

  // --- Feature: alertes ---
  sl.registerLazySingleton<AlertesRemoteDataSource>(
    () => AlertesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AlertesRepository>(
    () => AlertesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ListerAlertesUseCase(sl()));

  // --- Feature: historique ---
  sl.registerLazySingleton<HistoriqueRemoteDataSource>(
    () => HistoriqueRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HistoriqueRepository>(
    () => HistoriqueRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ListerHistoriqueUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirResultatUseCase(sl()));

  // --- Feature: modeles ---
  sl.registerLazySingleton<ModelesRemoteDataSource>(
    () => ModelesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ModelesRepository>(
    () => ModelesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ListerModelesUseCase(sl()));
}
