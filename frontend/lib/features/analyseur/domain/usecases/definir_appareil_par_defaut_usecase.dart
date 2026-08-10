import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/analyseur_repository.dart';

class DefinirAppareilParDefautUseCase implements UseCase<void, String?> {
  final AnalyseurRepository repository;

  const DefinirAppareilParDefautUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String? params) async {
    await repository.definirAppareilParDefaut(params);
    return const Right(null);
  }
}
