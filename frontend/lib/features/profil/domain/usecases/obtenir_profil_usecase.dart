import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profil_entity.dart';
import '../repositories/profil_repository.dart';

class ObtenirProfilUseCase implements UseCase<ProfilEntity, NoParams> {
  final ProfilRepository repository;

  const ObtenirProfilUseCase(this.repository);

  @override
  Future<Either<Failure, ProfilEntity>> call(NoParams params) {
    return repository.obtenirProfil();
  }
}
