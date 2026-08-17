import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/cache_local_service.dart';
import '../../domain/entities/alerte_entity.dart';
import '../../domain/repositories/alertes_repository.dart';
import '../datasources/alertes_remote_datasource.dart';
import '../models/alerte_model.dart';

const _cleAlertesListe = 'alertes_liste';

class AlertesRepositoryImpl implements AlertesRepository {
  final AlertesRemoteDataSource remoteDataSource;
  final CacheLocalService cacheLocal;

  const AlertesRepositoryImpl({required this.remoteDataSource, required this.cacheLocal});

  @override
  Future<Either<Failure, List<AlerteEntity>>> listerAlertes() async {
    try {
      final alertes = await remoteDataSource.listerAlertes();
      await cacheLocal.ecrireListe(_cleAlertesListe, alertes.map((a) => a.toJson()).toList());
      return Right(alertes);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      final cache = await cacheLocal.lireListe(_cleAlertesListe);
      if (cache != null) return Right(cache.map(AlerteModel.fromJson).toList());
      return const Left(ErreurReseauFailure());
    }
  }
}
