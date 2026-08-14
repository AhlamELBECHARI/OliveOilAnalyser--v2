import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/utilisateur_admin_entity.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class DefinirActivationAdminParams extends Equatable {
  final int utilisateurId;
  final bool actif;

  const DefinirActivationAdminParams({required this.utilisateurId, required this.actif});

  @override
  List<Object?> get props => [utilisateurId, actif];
}

class DefinirActivationAdminUseCase
    implements UseCase<UtilisateurAdminEntity, DefinirActivationAdminParams> {
  final UtilisateursAdminRepository repository;

  const DefinirActivationAdminUseCase(this.repository);

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> call(DefinirActivationAdminParams params) {
    return repository.definirActivation(params.utilisateurId, params.actif);
  }
}
