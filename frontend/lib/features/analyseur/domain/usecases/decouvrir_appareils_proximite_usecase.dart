import '../entities/appareil_decouvert_entity.dart';
import '../repositories/analyseur_repository.dart';

/// Ne suit pas le contrat `UseCase<T, P>` (Future/Either) : voir
/// ObserverEtatConnexionUseCase — un flux continu de découverte n'a pas de
/// notion d'échec ponctuel unique à propager, la Presentation s'y abonne
/// directement.
class DecouvrirAppareilsProximiteUseCase {
  final AnalyseurRepository repository;

  const DecouvrirAppareilsProximiteUseCase(this.repository);

  Stream<AppareilDecouvertEntity> call() => repository.decouvrirAppareilsProximite();
}
