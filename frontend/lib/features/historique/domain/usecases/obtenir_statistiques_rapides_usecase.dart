import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/statistiques_rapides_entity.dart';
import '../repositories/historique_repository.dart';

class ObtenirStatistiquesRapidesUseCase implements UseCase<StatistiquesRapidesEntity, NoParams> {
  final HistoriqueRepository repository;

  const ObtenirStatistiquesRapidesUseCase(this.repository);

  @override
  Future<Either<Failure, StatistiquesRapidesEntity>> call(NoParams params) {
    return repository.obtenirStatistiquesRapides();
  }
}
