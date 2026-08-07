import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../local_storage/local_database.dart';
import '../navigation/app_navigator.dart';
import '../network/dio_client.dart';
import '../storage/token_storage_service.dart';
import '../sync/synchronisation_service.dart';
import '../../features/alertes/data/datasources/alertes_remote_datasource.dart';
import '../../features/analyseur/data/repositories/analyseur_bluetooth_impl.dart';
import '../../features/analyseur/data/repositories/analyseur_simule_impl.dart';
import '../../features/analyseur/domain/repositories/analyseur_repository.dart';
import '../../features/analyseur/domain/usecases/connecter_automatiquement_usecase.dart';
import '../../features/analyseur/domain/usecases/envoyer_commande_usecase.dart';
import '../../features/analyseur/domain/usecases/obtenir_info_appareil_usecase.dart';
import '../../features/analyseur/domain/usecases/observer_etat_connexion_usecase.dart';
import '../../features/analyseur/domain/usecases/observer_spectre_usecase.dart';
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
import '../../features/configuration/data/datasources/configuration_remote_datasource.dart';
import '../../features/configuration/data/repositories/configuration_repository_impl.dart';
import '../../features/configuration/domain/repositories/configuration_repository.dart';
import '../../features/configuration/domain/usecases/modifier_configuration_usecase.dart';
import '../../features/configuration/domain/usecases/obtenir_configuration_usecase.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/compter_alertes_non_resolues_usecase.dart';
import '../../features/dashboard/domain/usecases/obtenir_etat_analyseur_usecase.dart';
import '../../features/dashboard/domain/usecases/obtenir_statistiques_usecase.dart';
import '../../features/historique/data/datasources/historique_remote_datasource.dart';
import '../../features/historique/data/repositories/historique_repository_impl.dart';
import '../../features/historique/domain/repositories/historique_repository.dart';
import '../../features/historique/domain/usecases/declencher_export_usecase.dart';
import '../../features/historique/domain/usecases/lister_analyses_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_resultat_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_statistiques_rapides_usecase.dart';
import '../../features/modeles/data/datasources/modeles_remote_datasource.dart';
import '../../features/modeles/data/repositories/modeles_repository_impl.dart';
import '../../features/modeles/domain/repositories/modeles_repository.dart';
import '../../features/modeles/domain/usecases/lister_modeles_usecase.dart';
import '../../features/nouvelle_analyse/data/repositories/nouvelle_analyse_repository_impl.dart';
import '../../features/nouvelle_analyse/domain/repositories/nouvelle_analyse_repository.dart';
import '../../features/nouvelle_analyse/domain/usecases/enregistrer_echantillon_usecase.dart';
import '../../features/nouvelle_analyse/domain/usecases/enregistrer_spectre_usecase.dart';
import '../../features/parametres/data/datasources/parametres_local_datasource.dart';
import '../../features/parametres/data/repositories/parametres_repository_impl.dart';
import '../../features/parametres/domain/repositories/parametres_repository.dart';
import '../../features/parametres/domain/usecases/definir_locale_usecase.dart';
import '../../features/parametres/domain/usecases/definir_mode_theme_usecase.dart';
import '../../features/parametres/domain/usecases/obtenir_locale_usecase.dart';
import '../../features/parametres/domain/usecases/obtenir_mode_theme_usecase.dart';
import '../../features/profil/data/datasources/profil_remote_datasource.dart';
import '../../features/profil/data/repositories/profil_repository_impl.dart';
import '../../features/profil/domain/repositories/profil_repository.dart';
import '../../features/profil/domain/usecases/changer_mot_de_passe_usecase.dart';
import '../../features/profil/domain/usecases/lister_sessions_usecase.dart';
import '../../features/profil/domain/usecases/modifier_profil_usecase.dart';
import '../../features/profil/domain/usecases/obtenir_profil_usecase.dart';
import '../../features/profil/domain/usecases/revoquer_session_usecase.dart';
import '../../features/profil/domain/usecases/televerser_photo_profil_usecase.dart';

/// Conteneur d'injection de dépendances (get_it). C'est la seule "racine de
/// composition" de l'application : la Presentation ne connaît que les
/// UseCases exposés ici, jamais Dio ni le secure storage directement.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Core ---
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());
  sl.registerLazySingleton<AppNavigator>(() => AppNavigator());
  sl.registerLazySingleton<LocalDatabase>(() => LocalDatabase());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<DioClient>(() => DioClient(
        tokenStorage: sl(),
        onSessionExpiree: () => sl<AppNavigator>().retourAuLogin(),
      ));
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Synchronisation hors ligne (voir core/local_storage/local_database.dart) :
  // un seul service, partagé par toute l'app, qui pousse vers l'API tout ce
  // qui a été écrit localement en attendant le réseau. Démarré une seule
  // fois ici (écoute de la connectivité), jamais réinstancié par écran.
  sl.registerLazySingleton<SynchronisationService>(
    () => SynchronisationService(base: sl(), dio: sl(), preferences: sl()),
  );
  sl<SynchronisationService>().demarrerEcoute();

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

  // --- Feature: analyseur (module Bluetooth) ---
  // Seul point de choix entre le simulateur et la vraie implémentation SPP
  // (voir AppConfig.utiliserAnalyseurSimule) : jamais de `if` dispersé
  // ailleurs, l'UI ne dépend que d'AnalyseurRepository.
  sl.registerLazySingleton<AnalyseurRepository>(
    () => AppConfig.utiliserAnalyseurSimule ? AnalyseurSimuleImpl() : AnalyseurBluetoothImpl(),
  );
  sl.registerLazySingleton(() => ConnecterAutomatiquementUseCase(sl()));
  sl.registerLazySingleton(() => EnvoyerCommandeUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirInfoAppareilUseCase(sl()));
  sl.registerLazySingleton(() => ObserverEtatConnexionUseCase(sl()));
  sl.registerLazySingleton(() => ObserverSpectreUseCase(sl()));

  // --- Feature: nouvelle_analyse ---
  // Écrit toujours d'abord en local (LocalDatabase) avant toute tentative
  // réseau (SynchronisationService) — voir NouvelleAnalyseRepositoryImpl.
  sl.registerLazySingleton<NouvelleAnalyseRepository>(
    () => NouvelleAnalyseRepositoryImpl(base: sl(), synchronisation: sl()),
  );
  sl.registerLazySingleton(() => EnregistrerEchantillonUseCase(sl()));
  sl.registerLazySingleton(() => EnregistrerSpectreUseCase(sl()));

  // --- Feature: dashboard ---
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
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
  sl.registerLazySingleton(() => ObtenirModeThemeUseCase(sl()));
  sl.registerLazySingleton(() => DefinirModeThemeUseCase(sl()));

  // --- Feature: configuration (seuils, notifications) ---
  sl.registerLazySingleton<ConfigurationRemoteDataSource>(
    () => ConfigurationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ConfigurationRepository>(
    () => ConfigurationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ObtenirConfigurationUseCase(sl()));
  sl.registerLazySingleton(() => ModifierConfigurationUseCase(sl()));

  // --- Feature: profil ---
  sl.registerLazySingleton<ProfilRemoteDataSource>(
    () => ProfilRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProfilRepository>(
    () => ProfilRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton(() => ObtenirProfilUseCase(sl()));
  sl.registerLazySingleton(() => ModifierProfilUseCase(sl()));
  sl.registerLazySingleton(() => TeleverserPhotoProfilUseCase(sl()));
  sl.registerLazySingleton(() => ChangerMotDePasseUseCase(sl()));
  sl.registerLazySingleton(() => ListerSessionsUseCase(sl()));
  sl.registerLazySingleton(() => RevoquerSessionUseCase(sl()));

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
  sl.registerLazySingleton(() => ListerAnalysesUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirStatistiquesRapidesUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirResultatUseCase(sl()));
  sl.registerLazySingleton(() => DeclencherExportUseCase(sl()));

  // --- Feature: modeles ---
  sl.registerLazySingleton<ModelesRemoteDataSource>(
    () => ModelesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ModelesRepository>(
    () => ModelesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ListerModelesUseCase(sl()));
}
