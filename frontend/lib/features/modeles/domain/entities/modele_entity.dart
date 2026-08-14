import 'package:equatable/equatable.dart';

enum TypeModele { regression, classification }

TypeModele typeModeleDepuisCode(String code) {
  return code == 'classification' ? TypeModele.classification : TypeModele.regression;
}

enum GrandeurPredite { acidite, indicePeroxyde, authenticite }

GrandeurPredite grandeurPrediteDepuisCode(String code) {
  switch (code) {
    case 'indice_peroxyde':
      return GrandeurPredite.indicePeroxyde;
    case 'authenticite':
      return GrandeurPredite.authenticite;
    default:
      return GrandeurPredite.acidite;
  }
}

class ModeleEntity extends Equatable {
  final int id;
  final String nom;
  final String version;
  final String algorithme;
  final TypeModele typeModele;
  final GrandeurPredite grandeurPredite;
  // Régression uniquement.
  final double? r2;
  final double? rmsecv;
  // Classification uniquement.
  final double? exactitude;
  final double? precisionClassification;
  final double? rappel;
  final bool estReference;
  final bool estActif;
  final bool estDeprecie;
  final DateTime? dateEntrainement;

  const ModeleEntity({
    required this.id,
    required this.nom,
    required this.version,
    required this.algorithme,
    required this.typeModele,
    required this.grandeurPredite,
    required this.r2,
    required this.rmsecv,
    required this.exactitude,
    required this.precisionClassification,
    required this.rappel,
    required this.estReference,
    required this.estActif,
    required this.estDeprecie,
    required this.dateEntrainement,
  });

  @override
  List<Object?> get props => [
        id,
        nom,
        version,
        algorithme,
        typeModele,
        grandeurPredite,
        r2,
        rmsecv,
        exactitude,
        precisionClassification,
        rappel,
        estReference,
        estActif,
        estDeprecie,
        dateEntrainement,
      ];
}
