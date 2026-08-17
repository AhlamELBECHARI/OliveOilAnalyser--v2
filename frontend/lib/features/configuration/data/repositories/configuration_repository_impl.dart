import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/cache_local_service.dart';
import '../../domain/entities/configuration_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_remote_datasource.dart';
import '../models/configuration_model.dart';

class ConfigurationRepositoryImpl implements ConfigurationRepository {
  final ConfigurationRemoteDataSource remoteDataSource;
  final CacheLocalService cacheLocal;

  const ConfigurationRepositoryImpl({required this.remoteDataSource, required this.cacheLocal});

  /// Lecture-first hors ligne : la Configuration (seuils) doit rester
  /// disponible sans réseau pour que le calcul de conformité/catégorie
  /// reste possible pendant une analyse (cahier des charges, Partie A,
  /// section 4).
  @override
  Future<Either<Failure, ConfigurationEntity>> obtenirConfiguration() async {
    try {
      final configuration = await remoteDataSource.obtenirConfiguration();
      await cacheLocal.ecrireMap(CleCache.configuration, configuration.toJson());
      return Right(configuration);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      final cache = await cacheLocal.lireMap(CleCache.configuration);
      if (cache != null) return Right(ConfigurationModel.fromJson(cache));
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ConfigurationEntity>> modifierConfiguration(
    ConfigurationEntity configuration,
  ) async {
    try {
      final modifiee = await remoteDataSource
          .modifierConfiguration(ConfigurationModel.depuisEntite(configuration));
      await cacheLocal.ecrireMap(CleCache.configuration, modifiee.toJson());
      return Right(modifiee);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
