import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/historique_repository.dart';

class TelechargerRapportUseCase implements UseCase<List<int>, String> {
  final HistoriqueRepository repository;

  const TelechargerRapportUseCase(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(String params) {
    return repository.telechargerRapport(params);
  }
}
