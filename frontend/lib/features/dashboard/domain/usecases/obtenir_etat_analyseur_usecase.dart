import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/etat_analyseur_entity.dart';
import '../repositories/etat_analyseur_repository.dart';

class ObtenirEtatAnalyseurUseCase implements UseCase<EtatAnalyseurEntity, NoParams> {
  final EtatAnalyseurRepository repository;

  const ObtenirEtatAnalyseurUseCase(this.repository);

  @override
  Future<Either<Failure, EtatAnalyseurEntity>> call(NoParams params) async {
    return Right(await repository.obtenirEtatActuel());
  }
}
