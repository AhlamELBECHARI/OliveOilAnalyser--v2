import '../../domain/entities/etat_analyseur_entity.dart';
import '../../domain/repositories/etat_analyseur_repository.dart';

/// Implémentation factice de [EtatAnalyseurRepository], en attendant le
/// développement du module Bluetooth réel. Renvoie un état plausible mais
/// statique. À remplacer par une implémentation adossée au vrai module
/// Bluetooth — la carte "État du laboratoire" du dashboard ne dépendant que
/// de l'interface [EtatAnalyseurRepository], aucun changement d'UI ne sera
/// nécessaire à ce moment-là.
class EtatAnalyseurRepositoryFakeImpl implements EtatAnalyseurRepository {
  @override
  Future<EtatAnalyseurEntity> obtenirEtatActuel() async {
    return EtatAnalyseurEntity(
      appareilConnecte: true,
      nomAppareil: 'NIR-Scan Pro',
      bluetoothActif: true,
      niveauBatteriePourcentage: 82,
      derniereSynchronisation: DateTime.now().subtract(const Duration(minutes: 12)),
    );
  }
}
