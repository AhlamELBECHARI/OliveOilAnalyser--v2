import 'package:equatable/equatable.dart';

/// Un appareil Bluetooth Classic détecté par une recherche active
/// (découverte), qu'il soit déjà appairé ou non — voir
/// AnalyseurRepository.decouvrirAppareilsProximite. Distinct de
/// [AppareilAppaireEntity] : celui-ci ne vient jamais d'un simple appairage
/// système, toujours d'un balayage en cours.
class AppareilDecouvertEntity extends Equatable {
  final String adresse;
  final String nom;

  /// Force du signal (dBm, valeurs négatives — plus proche de 0 = plus
  /// fort), `null` si l'appareil ou la plateforme ne la fournit pas.
  final int? forceSignal;
  final bool dejaAppaire;

  const AppareilDecouvertEntity({
    required this.adresse,
    required this.nom,
    this.forceSignal,
    required this.dejaAppaire,
  });

  @override
  List<Object?> get props => [adresse, nom, forceSignal, dejaAppaire];
}
