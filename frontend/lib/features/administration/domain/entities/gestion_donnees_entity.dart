import 'package:equatable/equatable.dart';

class StatistiquesOccupationEntity extends Equatable {
  final int echantillons;
  final int spectres;
  final int resultats;
  final int modeles;
  final int utilisateurs;
  final int tailleBaseOctets;

  const StatistiquesOccupationEntity({
    required this.echantillons,
    required this.spectres,
    required this.resultats,
    required this.modeles,
    required this.utilisateurs,
    required this.tailleBaseOctets,
  });

  @override
  List<Object?> get props =>
      [echantillons, spectres, resultats, modeles, utilisateurs, tailleBaseOctets];
}

class PurgeApercuEntity extends Equatable {
  final int echantillonsASupprimer;
  final int spectresASupprimer;
  final int resultatsASupprimer;

  const PurgeApercuEntity({
    required this.echantillonsASupprimer,
    required this.spectresASupprimer,
    required this.resultatsASupprimer,
  });

  @override
  List<Object?> get props => [echantillonsASupprimer, spectresASupprimer, resultatsASupprimer];
}
