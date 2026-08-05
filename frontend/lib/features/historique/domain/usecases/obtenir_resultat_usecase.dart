import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/resultat_historique_entity.dart';
import '../repositories/historique_repository.dart';

class ObtenirResultatUseCase implements UseCase<ResultatHistoriqueEntity, String> {
  final HistoriqueRepository repository;

  const ObtenirResultatUseCase(this.repository);

  @override
  Future<Either<Failure, ResultatHistoriqueEntity>> call(String resultatId) {
    return repository.obtenirResultat(resultatId);
  }
}
