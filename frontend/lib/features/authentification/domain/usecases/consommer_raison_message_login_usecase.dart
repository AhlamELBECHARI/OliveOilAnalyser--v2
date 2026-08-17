import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/raison_message_login.dart';
import '../repositories/auth_repository.dart';

/// Lit puis efface la raison d'un message informatif en attente pour
/// l'écran de connexion (session expirée hors ligne, déconnexion hors
/// ligne...) — appelé une seule fois à l'initialisation de LoginScreen.
class ConsommerRaisonMessageLoginUseCase implements UseCase<RaisonMessageLogin, NoParams> {
  final AuthRepository repository;

  const ConsommerRaisonMessageLoginUseCase(this.repository);

  @override
  Future<Either<Failure, RaisonMessageLogin>> call(NoParams params) async {
    return Right(await repository.consommerRaisonMessageLogin());
  }
}
