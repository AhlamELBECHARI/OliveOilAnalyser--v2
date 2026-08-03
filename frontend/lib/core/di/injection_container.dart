import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../navigation/app_navigator.dart';
import '../network/dio_client.dart';
import '../storage/token_storage_service.dart';
import '../../features/authentification/data/datasources/auth_local_datasource.dart';
import '../../features/authentification/data/datasources/auth_remote_datasource.dart';
import '../../features/authentification/data/repositories/auth_repository_impl.dart';
import '../../features/authentification/domain/repositories/auth_repository.dart';
import '../../features/authentification/domain/usecases/demander_reset_mot_de_passe_usecase.dart';
import '../../features/authentification/domain/usecases/get_session_locale_usecase.dart';
import '../../features/authentification/domain/usecases/login_usecase.dart';
import '../../features/authentification/domain/usecases/logout_usecase.dart';

/// Conteneur d'injection de dépendances (get_it). C'est la seule "racine de
/// composition" de l'application : la Presentation ne connaît que les
/// UseCases exposés ici, jamais Dio ni le secure storage directement.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Core ---
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  sl.registerLazySingleton<AppNavigator>(() => AppNavigator());

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
  sl.registerLazySingleton(() => GetSessionLocaleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
}
