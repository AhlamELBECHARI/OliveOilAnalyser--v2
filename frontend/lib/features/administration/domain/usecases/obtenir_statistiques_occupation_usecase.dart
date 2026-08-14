import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/gestion_donnees_entity.dart';
import '../repositories/administration_repository.dart';

class ObtenirStatistiquesOccupationUseCase
    implements UseCase<StatistiquesOccupationEntity, NoParams> {
  final AdministrationRepository repository;

  const ObtenirStatistiquesOccupationUseCase(this.repository);

  @override
  Future<Either<Failure, StatistiquesOccupationEntity>> call(NoParams params) {
    return repository.obtenirStatistiquesOccupation();
  }
}
