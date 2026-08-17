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

  /// Pour le cache local des modèles actifs (voir
  /// core/local_storage/cache_local_service.dart), nécessaire au calcul de
  /// conformité hors ligne — même forme que la réponse API.
  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'version': version,
        'algorithme': algorithme,
        'type_modele': typeModele == TypeModele.classification ? 'classification' : 'regression',
        'grandeur_predite': switch (grandeurPredite) {
          GrandeurPredite.indicePeroxyde => 'indice_peroxyde',
          GrandeurPredite.authenticite => 'authenticite',
          GrandeurPredite.acidite => 'acidite',
        },
        'r2': r2,
        'rmsecv': rmsecv,
        'exactitude': exactitude,
        'precision_classification': precisionClassification,
        'rappel': rappel,
        'est_reference': estReference,
        'est_actif': estActif,
        'est_deprecie': estDeprecie,
        'date_entrainement': dateEntrainement?.toIso8601String(),
      };
}
