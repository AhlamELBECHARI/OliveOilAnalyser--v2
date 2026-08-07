import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/profil_repository.dart';

class ListerSessionsUseCase implements UseCase<List<SessionEntity>, NoParams> {
  final ProfilRepository repository;

  const ListerSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(NoParams params) {
    return repository.listerSessions();
  }
}
