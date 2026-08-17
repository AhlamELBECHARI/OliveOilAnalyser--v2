import '../../domain/entities/profil_entity.dart';

class ProfilModel extends ProfilEntity {
  const ProfilModel({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
    required super.telephone,
    required super.fonction,
    required super.laboratoire,
    required super.institution,
    super.photoProfilUrl,
    super.dateDerniereConnexion,
    required super.dateCreation,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      telephone: json['telephone'] as String,
      fonction: json['fonction'] as String,
      laboratoire: json['laboratoire'] as String,
      institution: json['institution'] as String,
      photoProfilUrl: json['photo_profil'] as String?,
      dateDerniereConnexion: json['date_derniere_connexion'] == null
          ? null
          : DateTime.parse(json['date_derniere_connexion'] as String),
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  /// Pour le cache local hors ligne (voir core/local_storage/cache_local_service.dart)
  /// — même forme que la réponse API, pour que [fromJson] puisse relire tel quel.
  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'role': role,
        'telephone': telephone,
        'fonction': fonction,
        'laboratoire': laboratoire,
        'institution': institution,
        'photo_profil': photoProfilUrl,
        'date_derniere_connexion': dateDerniereConnexion?.toIso8601String(),
        'date_creation': dateCreation.toIso8601String(),
      };
}
