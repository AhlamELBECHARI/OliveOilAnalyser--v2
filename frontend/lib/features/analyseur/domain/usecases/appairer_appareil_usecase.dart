import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class AppairerAppareilUseCase implements UseCase<bool, String> {
  final AnalyseurRepository repository;

  const AppairerAppareilUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String adresse) async {
    return Right(await repository.appairerAppareil(adresse));
  }
}
