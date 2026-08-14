import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class DeclencherResetMotDePasseAdminUseCase implements UseCase<void, int> {
  final UtilisateursAdminRepository repository;

  const DeclencherResetMotDePasseAdminUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int utilisateurId) {
    return repository.declencherResetMotDePasse(utilisateurId);
  }
}
