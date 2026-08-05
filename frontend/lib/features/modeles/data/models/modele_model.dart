import '../../domain/entities/modele_entity.dart';

class ModeleModel extends ModeleEntity {
  const ModeleModel({
    required super.id,
    required super.nom,
    required super.version,
    required super.algorithme,
    required super.r2,
    required super.rmsecv,
    required super.estActif,
    required super.estDeprecie,
    required super.dateEntrainement,
  });

  factory ModeleModel.fromJson(Map<String, dynamic> json) {
    return ModeleModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      version: json['version'] as String,
      algorithme: json['algorithme'] as String,
      r2: (json['r2'] as num).toDouble(),
      rmsecv: (json['rmsecv'] as num).toDouble(),
      estActif: json['est_actif'] as bool,
      estDeprecie: json['est_deprecie'] as bool,
      dateEntrainement: json['date_entrainement'] == null
          ? null
          : DateTime.parse(json['date_entrainement'] as String),
    );
  }
}
