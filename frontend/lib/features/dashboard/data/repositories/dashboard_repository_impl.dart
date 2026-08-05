import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({required this.remoteDataSource});

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
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, int>> compterAlertesNonResolues() async {
    try {
      final compte = await remoteDataSource.compterAlertesNonResolues();
      return Right(compte);
    } catch (_) {
      // La pastille de notifications ne doit jamais faire échouer tout le
      // dashboard : en cas d'erreur, on considère simplement "pas d'alerte".
      return const Right(0);
    }
  }
}
