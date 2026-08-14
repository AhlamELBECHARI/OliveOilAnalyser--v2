import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/gestion_donnees_entity.dart';
import '../repositories/administration_repository.dart';

class PrevisualiserPurgeUseCase implements UseCase<PurgeApercuEntity, DateTime> {
  final AdministrationRepository repository;

  const PrevisualiserPurgeUseCase(this.repository);

  @override
  Future<Either<Failure, PurgeApercuEntity>> call(DateTime dateLimite) {
    return repository.previsualiserPurge(dateLimite);
  }
}
