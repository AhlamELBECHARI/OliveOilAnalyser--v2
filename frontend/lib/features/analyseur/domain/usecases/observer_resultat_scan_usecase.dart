import '../entities/resultat_scan_entity.dart';
import '../repositories/analyseur_repository.dart';

/// Voir observer_etat_connexion_usecase.dart pour la raison de ne pas
/// suivre le contrat `UseCase<T, P>` ici : un flux n'a pas d'échec
/// ponctuel à propager.
class ObserverResultatScanUseCase {
  final AnalyseurRepository repository;

  const ObserverResultatScanUseCase(this.repository);

  Stream<ResultatScanEntity> call() => repository.flusResultat;
}
