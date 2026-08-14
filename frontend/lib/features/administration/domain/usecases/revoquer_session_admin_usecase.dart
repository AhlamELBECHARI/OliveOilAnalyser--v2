import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class RevoquerSessionAdminParams extends Equatable {
  final int utilisateurId;
  final int sessionId;

  const RevoquerSessionAdminParams({required this.utilisateurId, required this.sessionId});

  @override
  List<Object?> get props => [utilisateurId, sessionId];
}

class RevoquerSessionAdminUseCase implements UseCase<void, RevoquerSessionAdminParams> {
  final UtilisateursAdminRepository repository;

  const RevoquerSessionAdminUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RevoquerSessionAdminParams params) {
    return repository.revoquerSession(params.utilisateurId, params.sessionId);
  }
}
