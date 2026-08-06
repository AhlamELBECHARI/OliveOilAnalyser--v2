import '../entities/etat_connexion_analyseur_entity.dart';
import '../repositories/analyseur_repository.dart';

/// Ne suit pas le contrat `UseCase<T, P>` (Future/Either) : un flux continu
/// n'a pas de notion d'échec ponctuel à propager — une coupure ou une
/// erreur de connexion est un état du flux ([EtatConnexion.erreur]), pas
/// une exception. La Presentation s'y abonne directement (ex. via un
/// StreamProvider Riverpod).
class ObserverEtatConnexionUseCase {
  final AnalyseurRepository repository;

  const ObserverEtatConnexionUseCase(this.repository);

  Stream<EtatConnexionAnalyseurEntity> call() => repository.flusEtatConnexion;
}
