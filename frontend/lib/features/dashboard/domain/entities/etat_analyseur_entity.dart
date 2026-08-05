import 'package:equatable/equatable.dart';

/// État de la connexion à l'analyseur spectroscopique (Bluetooth). Le module
/// Bluetooth réel n'est pas encore développé : voir
/// domain/repositories/etat_analyseur_repository.dart pour l'abstraction qui
/// permettra de brancher une vraie implémentation sans changer l'UI.
class EtatAnalyseurEntity extends Equatable {
  final bool appareilConnecte;
  final String? nomAppareil;
  final bool bluetoothActif;
  final int? niveauBatteriePourcentage;
  final DateTime? derniereSynchronisation;

  const EtatAnalyseurEntity({
    required this.appareilConnecte,
    this.nomAppareil,
    required this.bluetoothActif,
    this.niveauBatteriePourcentage,
    this.derniereSynchronisation,
  });

  bool get estOperationnel => appareilConnecte && bluetoothActif;

  @override
  List<Object?> get props => [
        appareilConnecte,
        nomAppareil,
        bluetoothActif,
        niveauBatteriePourcentage,
        derniereSynchronisation,
      ];
}
