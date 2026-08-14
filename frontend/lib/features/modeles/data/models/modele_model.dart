import '../../domain/entities/modele_entity.dart';

class ModeleModel extends ModeleEntity {
  const ModeleModel({
    required super.id,
    required super.nom,
    required super.version,
    required super.algorithme,
    required super.typeModele,
    required super.grandeurPredite,
    required super.r2,
    required super.rmsecv,
    required super.exactitude,
    required super.precisionClassification,
    required super.rappel,
    required super.estReference,
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
      typeModele: typeModeleDepuisCode(json['type_modele'] as String),
      grandeurPredite: grandeurPrediteDepuisCode(json['grandeur_predite'] as String),
      r2: (json['r2'] as num?)?.toDouble(),
      rmsecv: (json['rmsecv'] as num?)?.toDouble(),
      exactitude: (json['exactitude'] as num?)?.toDouble(),
      precisionClassification: (json['precision_classification'] as num?)?.toDouble(),
      rappel: (json['rappel'] as num?)?.toDouble(),
      estReference: json['est_reference'] as bool,
      estActif: json['est_actif'] as bool,
      estDeprecie: json['est_deprecie'] as bool,
      dateEntrainement: json['date_entrainement'] == null
          ? null
          : DateTime.parse(json['date_entrainement'] as String),
    );
  }
}
