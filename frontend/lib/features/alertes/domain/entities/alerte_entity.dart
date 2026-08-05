import 'package:equatable/equatable.dart';

enum NiveauGravite { info, avertissement, critique }

NiveauGravite niveauGraviteDepuisCode(String code) {
  switch (code) {
    case 'avertissement':
      return NiveauGravite.avertissement;
    case 'critique':
      return NiveauGravite.critique;
    default:
      return NiveauGravite.info;
  }
}

class AlerteEntity extends Equatable {
  final int id;
  final String type;
  final String message;
  final NiveauGravite niveauGravite;
  final DateTime dateCreation;
  final bool estResolue;

  const AlerteEntity({
    required this.id,
    required this.type,
    required this.message,
    required this.niveauGravite,
    required this.dateCreation,
    required this.estResolue,
  });

  @override
  List<Object?> get props => [id, type, message, niveauGravite, dateCreation, estResolue];
}
