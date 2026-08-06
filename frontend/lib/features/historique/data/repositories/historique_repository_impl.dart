import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';
import '../../domain/repositories/historique_repository.dart';
import '../datasources/historique_remote_datasource.dart';

class HistoriqueRepositoryImpl implements HistoriqueRepository {
  final HistoriqueRemoteDataSource remoteDataSource;

  const HistoriqueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PageAnalysesHistorique>> listerAnalyses({
    required int page,
    FiltresHistorique filtres = const FiltresHistorique(),
  }) async {
    try {
      final resultat = await remoteDataSource.listerAnalyses(page: page, filtres: filtres);
      return Right(
        PageAnalysesHistorique(analyses: resultat.analyses, aPageSuivante: resultat.aPageSuivante),
      );
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, StatistiquesRapidesEntity>> obtenirStatistiquesRapides() async {
    try {
      return Right(await remoteDataSource.obtenirStatistiquesRapides());
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

  @override
  Future<Either<Failure, void>> declencherExport(String format) async {
    try {
      await remoteDataSource.declencherExport(format);
      return const Right(null);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
