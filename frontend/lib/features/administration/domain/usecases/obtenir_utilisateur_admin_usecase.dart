import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/utilisateur_admin_entity.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class ObtenirUtilisateurAdminUseCase implements UseCase<UtilisateurAdminEntity, int> {
  final UtilisateursAdminRepository repository;

  const ObtenirUtilisateurAdminUseCase(this.repository);

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> call(int id) => repository.obtenirUtilisateur(id);
}
