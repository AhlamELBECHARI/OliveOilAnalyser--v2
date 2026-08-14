import 'package:equatable/equatable.dart';

class UtilisateurAdminEntity extends Equatable {
  final int id;
  final String nom;
  final String email;
  final String role;
  final bool estActif;
  final bool isStaff;
  final int tentativesEchouees;
  final DateTime? verrouilleJusquA;
  final DateTime? dateDerniereConnexion;
  final DateTime dateCreation;
  final int nombreAnalyses;

  const UtilisateurAdminEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.estActif,
    required this.isStaff,
    required this.tentativesEchouees,
    required this.verrouilleJusquA,
    required this.dateDerniereConnexion,
    required this.dateCreation,
    required this.nombreAnalyses,
  });

  bool get estAdministrateur => role == 'administrateur';

  bool get estVerrouille => verrouilleJusquA != null && verrouilleJusquA!.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        nom,
        email,
        role,
        estActif,
        isStaff,
        tentativesEchouees,
        verrouilleJusquA,
        dateDerniereConnexion,
        dateCreation,
        nombreAnalyses,
      ];
}
