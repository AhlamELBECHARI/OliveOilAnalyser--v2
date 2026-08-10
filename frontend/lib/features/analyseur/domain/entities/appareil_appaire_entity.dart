import 'package:equatable/equatable.dart';

/// Un appareil Bluetooth déjà appairé au système, tel que listé par l'écran
/// "Configuration de l'appareil" — [adresse] est l'identifiant stable utilisé
/// pour mémoriser l'appareil par défaut (le nom seul n'est pas fiable :
/// plusieurs appareils peuvent le partager).
class AppareilAppaireEntity extends Equatable {
  final String adresse;
  final String nom;

  const AppareilAppaireEntity({required this.adresse, required this.nom});

  @override
  List<Object?> get props => [adresse, nom];
}
