import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/historique_repository.dart';

class SupprimerResultatUseCase implements UseCase<void, String> {
  final HistoriqueRepository repository;

  const SupprimerResultatUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String resultatId) {
    return repository.supprimerResultat(resultatId);
  }
}
