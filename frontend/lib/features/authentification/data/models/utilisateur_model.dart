import '../../domain/entities/utilisateur_entity.dart';

class UtilisateurModel extends UtilisateurEntity {
  const UtilisateurModel({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
  });

  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
