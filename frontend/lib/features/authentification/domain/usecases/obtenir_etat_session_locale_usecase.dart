import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/etat_session_locale.dart';
import '../repositories/auth_repository.dart';

/// Vérifie au démarrage de l'app l'état de la session stockée localement,
/// pour permettre de sauter l'écran de login — y compris hors ligne, tant
/// que la dernière authentification réelle date de moins de 30 jours (voir
/// core/usecase/usecase.dart pour le contrat UseCase générique).
class ObtenirEtatSessionLocaleUseCase implements UseCase<EtatSessionLocale, NoParams> {
  final AuthRepository repository;

  const ObtenirEtatSessionLocaleUseCase(this.repository);

  @override
  Future<Either<Failure, EtatSessionLocale>> call(NoParams params) async {
    return Right(await repository.obtenirEtatSessionLocale());
  }
}
