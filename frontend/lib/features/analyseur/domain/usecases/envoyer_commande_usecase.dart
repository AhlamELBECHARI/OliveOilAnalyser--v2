import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/commande_analyseur.dart';
import '../repositories/analyseur_repository.dart';

class EnvoyerCommandeUseCase implements UseCase<void, CommandeAnalyseur> {
  final AnalyseurRepository repository;

  const EnvoyerCommandeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommandeAnalyseur params) async {
    try {
      await repository.envoyerCommande(params);
      return const Right(null);
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
