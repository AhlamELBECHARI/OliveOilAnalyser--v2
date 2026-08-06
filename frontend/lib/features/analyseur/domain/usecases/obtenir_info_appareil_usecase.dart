import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/info_appareil_analyseur_entity.dart';
import '../repositories/analyseur_repository.dart';

class ObtenirInfoAppareilUseCase implements UseCase<InfoAppareilAnalyseurEntity?, NoParams> {
  final AnalyseurRepository repository;

  const ObtenirInfoAppareilUseCase(this.repository);

  @override
  Future<Either<Failure, InfoAppareilAnalyseurEntity?>> call(NoParams params) async {
    return Right(await repository.obtenirInfoAppareil());
  }
}
