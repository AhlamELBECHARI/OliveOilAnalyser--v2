import 'package:equatable/equatable.dart';

class ModeleEntity extends Equatable {
  final int id;
  final String nom;
  final String version;
  final String algorithme;
  final double r2;
  final double rmsecv;
  final bool estActif;
  final bool estDeprecie;
  final DateTime? dateEntrainement;

  const ModeleEntity({
    required this.id,
    required this.nom,
    required this.version,
    required this.algorithme,
    required this.r2,
    required this.rmsecv,
    required this.estActif,
    required this.estDeprecie,
    required this.dateEntrainement,
  });

  @override
  List<Object?> get props =>
      [id, nom, version, algorithme, r2, rmsecv, estActif, estDeprecie, dateEntrainement];
}
