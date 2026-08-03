import 'package:equatable/equatable.dart';

class UtilisateurEntity extends Equatable {
  final int id;
  final String nom;
  final String email;
  final String role;

  const UtilisateurEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
  });

  bool get estAdministrateur => role == 'administrateur';

  @override
  List<Object?> get props => [id, nom, email, role];
}
