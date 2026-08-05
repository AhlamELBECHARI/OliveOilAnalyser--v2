import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/alerte_entity.dart';
import '../repositories/alertes_repository.dart';

class ListerAlertesUseCase implements UseCase<List<AlerteEntity>, NoParams> {
  final AlertesRepository repository;

  const ListerAlertesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AlerteEntity>>> call(NoParams params) {
    return repository.listerAlertes();
  }
}
