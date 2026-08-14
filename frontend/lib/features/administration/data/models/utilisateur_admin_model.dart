import '../../domain/entities/utilisateur_admin_entity.dart';

class UtilisateurAdminModel extends UtilisateurAdminEntity {
  const UtilisateurAdminModel({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
    required super.estActif,
    required super.isStaff,
    required super.tentativesEchouees,
    required super.verrouilleJusquA,
    required super.dateDerniereConnexion,
    required super.dateCreation,
    required super.nombreAnalyses,
  });

  factory UtilisateurAdminModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurAdminModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      estActif: json['est_actif'] as bool,
      isStaff: json['is_staff'] as bool,
      tentativesEchouees: json['tentatives_echouees'] as int,
      verrouilleJusquA: json['verrouille_jusqu_a'] == null
          ? null
          : DateTime.parse(json['verrouille_jusqu_a'] as String),
      dateDerniereConnexion: json['date_derniere_connexion'] == null
          ? null
          : DateTime.parse(json['date_derniere_connexion'] as String),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      nombreAnalyses: json['nombre_analyses'] as int? ?? 0,
    );
  }
}
