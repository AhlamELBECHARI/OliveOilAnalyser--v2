import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/cache_local_service.dart';
import '../../../../core/local_storage/statistiques_locales_service.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final StatistiquesLocalesService statistiquesLocales;
  final CacheLocalService cacheLocal;

  const DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.statistiquesLocales,
    required this.cacheLocal,
  });

  /// Lecture-first hors ligne : sur échec réseau, recalcule les mêmes
  /// agrégations localement à partir du cache d'analyses (cahier des
  /// charges, Partie A, section 3) plutôt que de laisser l'écran vide ou en
  /// chargement indéfini.
  @override
  Future<Either<Failure, StatistiquesDashboardEntity>> obtenirStatistiques() async {
    try {
      final modele = await remoteDataSource.obtenirStatistiques();
      return Right(modele);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      try {
        final profilCache = await cacheLocal.lireMap(CleCache.profil);
        final nomUtilisateur = profilCache?['nom'] as String? ?? '';
        return Right(await statistiquesLocales.statistiquesDashboard(
          nomUtilisateur: nomUtilisateur,
        ));
      } catch (_) {
        return const Left(ErreurReseauFailure());
      }
    }
  }

  @override
  Future<Either<Failure, int>> compterAlertesNonResolues() async {
    try {
      final compte = await remoteDataSource.compterAlertesNonResolues();
      await cacheLocal.ecrireMap(CleCache.alertesNonResolues, {'compte': compte});
      return Right(compte);
    } catch (_) {
      // La pastille de notifications ne doit jamais faire échouer tout le
      // dashboard : en cas d'erreur, on sert le dernier compte connu, sinon
      // "pas d'alerte" plutôt qu'une pastille bloquée en chargement.
      final cache = await cacheLocal.lireMap(CleCache.alertesNonResolues);
      return Right(cache?['compte'] as int? ?? 0);
    }
  }
}
