import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../local_storage/cache_local_service.dart';
import '../local_storage/local_database.dart';
import '../local_storage/statistiques_locales_service.dart';
import '../navigation/app_navigator.dart';
import '../network/connectivity_service.dart';
import '../network/dio_client.dart';
import '../network/token_refresher.dart';
import '../storage/token_storage_service.dart';
import '../sync/synchronisation_service.dart';
import '../../features/administration/data/datasources/administration_remote_datasource.dart';
import '../../features/administration/data/datasources/utilisateurs_admin_remote_datasource.dart';
import '../../features/administration/data/repositories/administration_repository_impl.dart';
import '../../features/administration/data/repositories/utilisateurs_admin_repository_impl.dart';
import '../../features/administration/domain/repositories/administration_repository.dart';
import '../../features/administration/domain/repositories/utilisateurs_admin_repository.dart';
import '../../features/administration/domain/usecases/changer_role_admin_usecase.dart';
import '../../features/administration/domain/usecases/creer_utilisateur_admin_usecase.dart';
import '../../features/administration/domain/usecases/declencher_reset_mot_de_passe_admin_usecase.dart';
import '../../features/administration/domain/usecases/definir_activation_admin_usecase.dart';
import '../../features/administration/domain/usecases/deverrouiller_admin_usecase.dart';
import '../../features/administration/domain/usecases/executer_purge_usecase.dart';
import '../../features/administration/domain/usecases/lister_journal_audit_usecase.dart';
import '../../features/administration/domain/usecases/lister_sessions_admin_usecase.dart';
import '../../features/administration/domain/usecases/lister_utilisateurs_admin_usecase.dart';
import '../../features/administration/domain/usecases/obtenir_statistiques_occupation_usecase.dart';
import '../../features/administration/domain/usecases/obtenir_supervision_usecase.dart';
import '../../features/administration/domain/usecases/obtenir_utilisateur_admin_usecase.dart';
import '../../features/administration/domain/usecases/previsualiser_purge_usecase.dart';
import '../../features/administration/domain/usecases/resoudre_alerte_usecase.dart';
import '../../features/administration/domain/usecases/revoquer_session_admin_usecase.dart';
import '../../features/alertes/data/datasources/alertes_remote_datasource.dart';
import '../../features/analyseur/data/local/appareil_prefere_datasource.dart';
import '../../features/analyseur/data/repositories/analyseur_bluetooth_impl.dart';
import '../../features/analyseur/data/repositories/analyseur_simule_impl.dart';
import '../../features/analyseur/domain/repositories/analyseur_repository.dart';
import '../../features/analyseur/domain/usecases/connecter_automatiquement_usecase.dart';
import '../../features/analyseur/domain/usecases/definir_appareil_par_defaut_usecase.dart';
import '../../features/analyseur/domain/usecases/envoyer_commande_usecase.dart';
import '../../features/analyseur/domain/usecases/lister_appareils_appaires_usecase.dart';
import '../../features/analyseur/domain/usecases/obtenir_appareil_par_defaut_usecase.dart';
import '../../features/analyseur/domain/usecases/obtenir_info_appareil_usecase.dart';
import '../../features/analyseur/domain/usecases/observer_etat_connexion_usecase.dart';
import '../../features/analyseur/domain/usecases/observer_resultat_scan_usecase.dart';
import '../../features/analyseur/domain/usecases/observer_spectre_usecase.dart';
import '../../features/analyseur/domain/usecases/tester_connexion_usecase.dart';
import '../../features/alertes/data/repositories/alertes_repository_impl.dart';
import '../../features/alertes/domain/repositories/alertes_repository.dart';
import '../../features/alertes/domain/usecases/lister_alertes_usecase.dart';
import '../../features/authentification/data/datasources/auth_local_datasource.dart';
import '../../features/authentification/data/datasources/auth_remote_datasource.dart';
import '../../features/authentification/data/repositories/auth_repository_impl.dart';
import '../../features/authentification/domain/repositories/auth_repository.dart';
import '../../features/authentification/domain/usecases/confirmer_reset_mot_de_passe_usecase.dart';
import '../../features/authentification/domain/usecases/consommer_raison_message_login_usecase.dart';
import '../../features/authentification/domain/usecases/demander_reset_mot_de_passe_usecase.dart';
import '../../features/authentification/domain/usecases/obtenir_etat_session_locale_usecase.dart';
import '../../features/authentification/domain/usecases/login_usecase.dart';
import '../../features/authentification/domain/usecases/logout_usecase.dart';
import '../../features/authentification/domain/usecases/obtenir_role_session_usecase.dart';
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
import '../../features/historique/domain/usecases/modifier_echantillon_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_resultat_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_spectre_pour_echantillon_usecase.dart';
import '../../features/historique/domain/usecases/obtenir_statistiques_rapides_usecase.dart';
import '../../features/historique/domain/usecases/supprimer_resultat_usecase.dart';
import '../../features/historique/domain/usecases/telecharger_rapport_usecase.dart';
import '../../features/modeles/data/datasources/modeles_remote_datasource.dart';
import '../../features/modeles/data/repositories/modeles_repository_impl.dart';
import '../../features/modeles/domain/repositories/modeles_repository.dart';
import '../../features/modeles/domain/usecases/creer_modele_usecase.dart';
import '../../features/modeles/domain/usecases/lister_modeles_usecase.dart';
import '../../features/modeles/domain/usecases/modifier_statut_modele_usecase.dart';
import '../../features/modeles/domain/usecases/televerser_fichier_modele_usecase.dart';
import '../../features/nouvelle_analyse/data/repositories/nouvelle_analyse_repository_impl.dart';
import '../../features/nouvelle_analyse/domain/repositories/nouvelle_analyse_repository.dart';
import '../../features/nouvelle_analyse/domain/usecases/enregistrer_echantillon_usecase.dart';
import '../../features/nouvelle_analyse/domain/usecases/enregistrer_resultat_usecase.dart';
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
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Cache de lecture hors ligne (voir core/local_storage) : partagé par
  // toutes les features qui doivent rester consultables sans réseau.
  sl.registerLazySingleton<CacheLocalService>(() => CacheLocalService(base: sl()));
  sl.registerLazySingleton<StatistiquesLocalesService>(
    () => StatistiquesLocalesService(base: sl()),
  );

  sl.registerLazySingleton<DioClient>(() => DioClient(
        tokenStorage: sl(),
        onSessionExpiree: () => sl<AppNavigator>().retourAuLogin(),
      ));
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  sl.registerLazySingleton<TokenRefresher>(() => sl<DioClient>().tokenRefresher);

  // Synchronisation hors ligne (voir core/local_storage/local_database.dart) :
  // un seul service, partagé par toute l'app, qui pousse vers l'API tout ce
  // qui a été écrit localement en attendant le réseau. Démarré une seule
  // fois ici (écoute de la connectivité), jamais réinstancié par écran.
  sl.registerLazySingleton<SynchronisationService>(
    () => SynchronisationService(
      base: sl(),
      dio: sl(),
      preferences: sl(),
      connectivite: sl(),
      tokenRefresher: sl(),
    ),
  );
  sl<SynchronisationService>().demarrerEcoute();

  // --- Feature: authentification ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(tokenStorage: sl(), preferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), connectivityService: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => DemanderResetMotDePasseUseCase(sl()));
  sl.registerLazySingleton(() => VerifierCodeResetUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmerResetMotDePasseUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirEtatSessionLocaleUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirRoleSessionUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ConsommerRaisonMessageLoginUseCase(sl()));

  // --- Feature: analyseur (module Bluetooth) ---
  // Seul point de choix entre le simulateur et la vraie implémentation SPP
  // (voir AppConfig.utiliserAnalyseurSimule) : jamais de `if` dispersé
  // ailleurs, l'UI ne dépend que d'AnalyseurRepository.
  sl.registerLazySingleton<AppareilPrefereDataSource>(
    () => AppareilPrefereDataSourceImpl(preferences: sl()),
  );
  sl.registerLazySingleton<AnalyseurRepository>(
    () => AppConfig.utiliserAnalyseurSimule
        ? AnalyseurSimuleImpl()
        : AnalyseurBluetoothImpl(appareilPrefere: sl()),
  );
  sl.registerLazySingleton(() => ConnecterAutomatiquementUseCase(sl()));
  sl.registerLazySingleton(() => EnvoyerCommandeUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirInfoAppareilUseCase(sl()));
  sl.registerLazySingleton(() => ObserverEtatConnexionUseCase(sl()));
  sl.registerLazySingleton(() => ObserverSpectreUseCase(sl()));
  sl.registerLazySingleton(() => ObserverResultatScanUseCase(sl()));
  sl.registerLazySingleton(() => ListerAppareilsAppairesUseCase(sl()));
  sl.registerLazySingleton(() => DefinirAppareilParDefautUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirAppareilParDefautUseCase(sl()));
  sl.registerLazySingleton(() => TesterConnexionUseCase(sl()));

  // --- Feature: nouvelle_analyse ---
  // Écrit toujours d'abord en local (LocalDatabase) avant toute tentative
  // réseau (SynchronisationService) — voir NouvelleAnalyseRepositoryImpl.
  sl.registerLazySingleton<NouvelleAnalyseRepository>(
    () => NouvelleAnalyseRepositoryImpl(base: sl(), synchronisation: sl()),
  );
  sl.registerLazySingleton(() => EnregistrerEchantillonUseCase(sl()));
  sl.registerLazySingleton(() => EnregistrerSpectreUseCase(sl()));
  sl.registerLazySingleton(() => EnregistrerResultatUseCase(sl()));

  // --- Feature: dashboard ---
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl(), statistiquesLocales: sl(), cacheLocal: sl()),
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
    () => ConfigurationRepositoryImpl(remoteDataSource: sl(), cacheLocal: sl()),
  );
  sl.registerLazySingleton(() => ObtenirConfigurationUseCase(sl()));
  sl.registerLazySingleton(() => ModifierConfigurationUseCase(sl()));

  // --- Feature: profil ---
  sl.registerLazySingleton<ProfilRemoteDataSource>(
    () => ProfilRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProfilRepository>(
    () => ProfilRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl(), cacheLocal: sl()),
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
    () => AlertesRepositoryImpl(remoteDataSource: sl(), cacheLocal: sl()),
  );
  sl.registerLazySingleton(() => ListerAlertesUseCase(sl()));

  // --- Feature: historique ---
  sl.registerLazySingleton<HistoriqueRemoteDataSource>(
    () => HistoriqueRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HistoriqueRepository>(
    () => HistoriqueRepositoryImpl(remoteDataSource: sl(), localDatabase: sl(), statistiquesLocales: sl()),
  );
  sl.registerLazySingleton(() => ListerAnalysesUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirStatistiquesRapidesUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirResultatUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirSpectrePourEchantillonUseCase(sl()));
  sl.registerLazySingleton(() => DeclencherExportUseCase(sl()));
  sl.registerLazySingleton(() => TelechargerRapportUseCase(sl()));
  sl.registerLazySingleton(() => SupprimerResultatUseCase(sl()));
  sl.registerLazySingleton(() => ModifierEchantillonUseCase(sl()));

  // --- Feature: modeles ---
  sl.registerLazySingleton<ModelesRemoteDataSource>(
    () => ModelesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ModelesRepository>(
    () => ModelesRepositoryImpl(remoteDataSource: sl(), cacheLocal: sl()),
  );
  sl.registerLazySingleton(() => ListerModelesUseCase(sl()));
  sl.registerLazySingleton(() => CreerModeleUseCase(sl()));
  sl.registerLazySingleton(() => TeleverserFichierModeleUseCase(sl()));
  sl.registerLazySingleton(() => ModifierStatutModeleUseCase(sl()));

  // --- Feature: administration (espace admin) ---
  sl.registerLazySingleton<AdministrationRemoteDataSource>(
    () => AdministrationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AdministrationRepository>(
    () => AdministrationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ObtenirSupervisionUseCase(sl()));
  sl.registerLazySingleton(() => ResoudreAlerteUseCase(sl()));
  sl.registerLazySingleton(() => ListerJournalAuditUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirStatistiquesOccupationUseCase(sl()));
  sl.registerLazySingleton(() => PrevisualiserPurgeUseCase(sl()));
  sl.registerLazySingleton(() => ExecuterPurgeUseCase(sl()));

  sl.registerLazySingleton<UtilisateursAdminRemoteDataSource>(
    () => UtilisateursAdminRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UtilisateursAdminRepository>(
    () => UtilisateursAdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ListerUtilisateursAdminUseCase(sl()));
  sl.registerLazySingleton(() => ObtenirUtilisateurAdminUseCase(sl()));
  sl.registerLazySingleton(() => CreerUtilisateurAdminUseCase(sl()));
  sl.registerLazySingleton(() => ChangerRoleAdminUseCase(sl()));
  sl.registerLazySingleton(() => DefinirActivationAdminUseCase(sl()));
  sl.registerLazySingleton(() => DeverrouillerAdminUseCase(sl()));
  sl.registerLazySingleton(() => DeclencherResetMotDePasseAdminUseCase(sl()));
  sl.registerLazySingleton(() => ListerSessionsAdminUseCase(sl()));
  sl.registerLazySingleton(() => RevoquerSessionAdminUseCase(sl()));
}
