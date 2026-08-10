import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/appareil_appaire_entity.dart';
import '../repositories/analyseur_repository.dart';

class ListerAppareilsAppairesUseCase implements UseCase<List<AppareilAppaireEntity>, NoParams> {
  final AnalyseurRepository repository;

  const ListerAppareilsAppairesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppareilAppaireEntity>>> call(NoParams params) async {
    return Right(await repository.listerAppareilsAppaires());
  }
}
