import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Vérifie au démarrage de l'app si une session est déjà stockée localement,
/// pour permettre de sauter l'écran de login (voir core/usecase/usecase.dart
/// pour le contrat UseCase générique).
class GetSessionLocaleUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  const GetSessionLocaleUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return Right(await repository.possedeSessionLocale());
  }
}
