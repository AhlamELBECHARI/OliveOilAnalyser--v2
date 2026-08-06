import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class ConnecterAutomatiquementUseCase implements UseCase<void, NoParams> {
  final AnalyseurRepository repository;

  const ConnecterAutomatiquementUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await repository.connecterAutomatiquement();
      return const Right(null);
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
