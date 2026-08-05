import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/modele_entity.dart';
import '../repositories/modeles_repository.dart';

class ListerModelesUseCase implements UseCase<List<ModeleEntity>, NoParams> {
  final ModelesRepository repository;

  const ListerModelesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ModeleEntity>>> call(NoParams params) {
    return repository.listerModeles();
  }
}
