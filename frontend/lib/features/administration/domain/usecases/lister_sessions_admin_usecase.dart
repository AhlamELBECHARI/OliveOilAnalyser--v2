import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../profil/domain/entities/session_entity.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class ListerSessionsAdminUseCase implements UseCase<List<SessionEntity>, int> {
  final UtilisateursAdminRepository repository;

  const ListerSessionsAdminUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(int utilisateurId) {
    return repository.listerSessions(utilisateurId);
  }
}
