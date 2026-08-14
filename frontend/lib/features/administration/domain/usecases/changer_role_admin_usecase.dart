import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/utilisateur_admin_entity.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class ChangerRoleAdminParams extends Equatable {
  final int utilisateurId;
  final String role;

  const ChangerRoleAdminParams({required this.utilisateurId, required this.role});

  @override
  List<Object?> get props => [utilisateurId, role];
}

class ChangerRoleAdminUseCase implements UseCase<UtilisateurAdminEntity, ChangerRoleAdminParams> {
  final UtilisateursAdminRepository repository;

  const ChangerRoleAdminUseCase(this.repository);

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> call(ChangerRoleAdminParams params) {
    return repository.changerRole(params.utilisateurId, params.role);
  }
}
