import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class ObtenirAppareilParDefautUseCase implements UseCase<String?, NoParams> {
  final AnalyseurRepository repository;

  const ObtenirAppareilParDefautUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return Right(await repository.obtenirAppareilParDefaut());
  }
}
