import 'package:equatable/equatable.dart';

/// Informations d'identification de l'analyseur physiquement connecté.
/// Toutes proviennent de l'appareil lui-même (réel ou simulé) — jamais de
/// valeur en dur côté UI.
class InfoAppareilAnalyseurEntity extends Equatable {
  final String nom;
  final String type;
  final String numeroSerie;
  final String firmware;
  final int? niveauBatteriePourcentage;

  const InfoAppareilAnalyseurEntity({
    required this.nom,
    required this.type,
    required this.numeroSerie,
    required this.firmware,
    this.niveauBatteriePourcentage,
  });

  @override
  List<Object?> get props => [nom, type, numeroSerie, firmware, niveauBatteriePourcentage];
}
