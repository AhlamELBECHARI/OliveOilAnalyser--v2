import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/dashboard_repository.dart';

class CompterAlertesNonResoluesUseCase implements UseCase<int, NoParams> {
  final DashboardRepository repository;

  const CompterAlertesNonResoluesUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.compterAlertesNonResolues();
  }
}
