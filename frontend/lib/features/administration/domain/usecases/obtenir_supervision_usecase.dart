import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supervision_entity.dart';
import '../repositories/administration_repository.dart';

class ObtenirSupervisionUseCase implements UseCase<SupervisionEntity, NoParams> {
  final AdministrationRepository repository;

  const ObtenirSupervisionUseCase(this.repository);

  @override
  Future<Either<Failure, SupervisionEntity>> call(NoParams params) {
    return repository.obtenirSupervision();
  }
}
