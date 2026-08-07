import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profil_repository.dart';

class RevoquerSessionUseCase implements UseCase<void, int> {
  final ProfilRepository repository;

  const RevoquerSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.revoquerSession(params);
  }
}
