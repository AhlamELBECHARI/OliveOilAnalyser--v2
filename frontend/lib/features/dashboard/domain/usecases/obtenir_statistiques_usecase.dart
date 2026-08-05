import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/statistiques_dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class ObtenirStatistiquesUseCase implements UseCase<StatistiquesDashboardEntity, NoParams> {
  final DashboardRepository repository;

  const ObtenirStatistiquesUseCase(this.repository);

  @override
  Future<Either<Failure, StatistiquesDashboardEntity>> call(NoParams params) {
    return repository.obtenirStatistiques();
  }
}
