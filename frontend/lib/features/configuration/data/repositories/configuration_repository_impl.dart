import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/configuration_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_remote_datasource.dart';
import '../models/configuration_model.dart';

class ConfigurationRepositoryImpl implements ConfigurationRepository {
  final ConfigurationRemoteDataSource remoteDataSource;

  const ConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ConfigurationEntity>> obtenirConfiguration() async {
    try {
      return Right(await remoteDataSource.obtenirConfiguration());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ConfigurationEntity>> modifierConfiguration(
    ConfigurationEntity configuration,
  ) async {
    try {
      return Right(
        await remoteDataSource
            .modifierConfiguration(ConfigurationModel.depuisEntite(configuration)),
      );
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
