import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alerte_entity.dart';
import '../../domain/repositories/alertes_repository.dart';
import '../datasources/alertes_remote_datasource.dart';

class AlertesRepositoryImpl implements AlertesRepository {
  final AlertesRemoteDataSource remoteDataSource;

  const AlertesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AlerteEntity>>> listerAlertes() async {
    try {
      final modeles = await remoteDataSource.listerAlertes();
      return Right(modeles);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
