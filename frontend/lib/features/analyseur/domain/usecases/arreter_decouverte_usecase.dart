import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class ArreterDecouverteUseCase implements UseCase<void, NoParams> {
  final AnalyseurRepository repository;

  const ArreterDecouverteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await repository.arreterDecouverte();
    return const Right(null);
  }
}
