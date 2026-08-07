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
}
