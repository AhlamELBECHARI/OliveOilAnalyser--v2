import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Voir GetSessionLocaleUseCase : même moment d'utilisation (démarrage de
/// l'app), pour choisir entre la coquille utilisateur et la coquille admin
/// sans appel réseau.
class ObtenirRoleSessionUseCase implements UseCase<String?, NoParams> {
  final AuthRepository repository;

  const ObtenirRoleSessionUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return Right(await repository.obtenirRoleSession());
  }
}
