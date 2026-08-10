import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class TesterConnexionUseCase implements UseCase<bool, String> {
  final AnalyseurRepository repository;

  const TesterConnexionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return Right(await repository.testerConnexion(params));
  }
}
