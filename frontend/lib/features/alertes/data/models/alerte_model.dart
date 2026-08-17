import '../../domain/entities/alerte_entity.dart';

class AlerteModel extends AlerteEntity {
  const AlerteModel({
    required super.id,
    required super.type,
    required super.message,
    required super.niveauGravite,
    required super.dateCreation,
    required super.estResolue,
  });

  factory AlerteModel.fromJson(Map<String, dynamic> json) {
    return AlerteModel(
      id: json['id'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      niveauGravite: niveauGraviteDepuisCode(json['niveau_gravite'] as String),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      estResolue: json['est_resolue'] as bool,
    );
  }

  /// Pour le cache local (voir core/local_storage/cache_local_service.dart)
  /// — même forme que la réponse API.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'message': message,
        'niveau_gravite': switch (niveauGravite) {
          NiveauGravite.avertissement => 'avertissement',
          NiveauGravite.critique => 'critique',
          NiveauGravite.info => 'info',
        },
        'date_creation': dateCreation.toIso8601String(),
        'est_resolue': estResolue,
      };
}
