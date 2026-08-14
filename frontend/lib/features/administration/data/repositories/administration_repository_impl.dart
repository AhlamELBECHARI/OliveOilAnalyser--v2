import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/gestion_donnees_entity.dart';
import '../../domain/entities/supervision_entity.dart';
import '../../domain/repositories/administration_repository.dart';
import '../datasources/administration_remote_datasource.dart';

class AdministrationRepositoryImpl implements AdministrationRepository {
  final AdministrationRemoteDataSource remoteDataSource;

  const AdministrationRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _executer<T>(Future<T> Function() appel) async {
    try {
      return Right(await appel());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, SupervisionEntity>> obtenirSupervision() {
    return _executer(remoteDataSource.obtenirSupervision);
  }

  @override
  Future<Either<Failure, void>> resoudreAlerte(int alerteId) {
    return _executer(() => remoteDataSource.resoudreAlerte(alerteId));
  }

  @override
  Future<Either<Failure, PageJournalAudit>> listerJournalAudit({required int page}) {
    return _executer(() async {
      final resultat = await remoteDataSource.listerJournalAudit(page: page);
      return PageJournalAudit(
        entrees: resultat.entrees,
        aPageSuivante: resultat.aPageSuivante,
        total: resultat.total,
      );
    });
  }

  @override
  Future<Either<Failure, StatistiquesOccupationEntity>> obtenirStatistiquesOccupation() {
    return _executer(remoteDataSource.obtenirStatistiquesOccupation);
  }

  @override
  Future<Either<Failure, PurgeApercuEntity>> previsualiserPurge(DateTime dateLimite) {
    return _executer(() => remoteDataSource.previsualiserPurge(dateLimite));
  }

  @override
  Future<Either<Failure, void>> executerPurge(DateTime dateLimite) {
    return _executer(() => remoteDataSource.executerPurge(dateLimite));
  }
}
