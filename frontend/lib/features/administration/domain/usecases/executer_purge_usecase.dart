import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/administration_repository.dart';

class ExecuterPurgeUseCase implements UseCase<void, DateTime> {
  final AdministrationRepository repository;

  const ExecuterPurgeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DateTime dateLimite) {
    return repository.executerPurge(dateLimite);
  }
}
