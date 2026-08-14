import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/administration_repository.dart';

class ResoudreAlerteUseCase implements UseCase<void, int> {
  final AdministrationRepository repository;

  const ResoudreAlerteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int alerteId) {
    return repository.resoudreAlerte(alerteId);
  }
}
