import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/repositories/historique_repository.dart';
import '../datasources/historique_remote_datasource.dart';

class HistoriqueRepositoryImpl implements HistoriqueRepository {
  final HistoriqueRemoteDataSource remoteDataSource;

  const HistoriqueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ResultatHistoriqueEntity>>> listerHistorique() async {
    try {
      final resultats = await remoteDataSource.listerHistorique();
      return Right(resultats);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ResultatHistoriqueEntity>> obtenirResultat(String resultatId) async {
    try {
      final resultat = await remoteDataSource.obtenirResultat(resultatId);
      return Right(resultat);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
