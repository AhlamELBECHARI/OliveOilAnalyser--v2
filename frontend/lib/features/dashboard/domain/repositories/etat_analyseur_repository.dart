import '../entities/etat_analyseur_entity.dart';

/// Abstraction de la connexion à l'analyseur spectroscopique. Le module
/// Bluetooth n'est pas encore développé : tant qu'il ne l'est pas, seule une
/// implémentation factice existe (voir data/repositories/
/// etat_analyseur_repository_fake_impl.dart). L'UI ne dépend que de cette
/// interface, jamais de l'implémentation : elle n'aura pas à changer quand le
/// vrai module Bluetooth sera branché.
abstract class EtatAnalyseurRepository {
  Future<EtatAnalyseurEntity> obtenirEtatActuel();
}
