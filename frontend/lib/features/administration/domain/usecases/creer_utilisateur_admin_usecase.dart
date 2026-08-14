import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/utilisateur_admin_entity.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class CreerUtilisateurAdminParams extends Equatable {
  final String nom;
  final String email;
  final String password;
  final String role;

  const CreerUtilisateurAdminParams({
    required this.nom,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [nom, email, password, role];
}

class CreerUtilisateurAdminUseCase
    implements UseCase<UtilisateurAdminEntity, CreerUtilisateurAdminParams> {
  final UtilisateursAdminRepository repository;

  const CreerUtilisateurAdminUseCase(this.repository);

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> call(CreerUtilisateurAdminParams params) {
    return repository.creerUtilisateur(
      nom: params.nom,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}
