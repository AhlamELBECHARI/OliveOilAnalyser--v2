import 'package:equatable/equatable.dart';

/// Miroir de GET/PATCH /api/utilisateurs/moi/. `role` est en lecture seule
/// (voir comptes.serializers.MonProfilSerializer côté backend) : aucun
/// champ de cette entité ne doit jamais être envoyé pour élever son propre
/// rôle, c'est structurellement impossible via cet endpoint.
class ProfilEntity extends Equatable {
  final int id;
  final String nom;
  final String email;
  final String role;
  final String telephone;
  final String fonction;
  final String laboratoire;
  final String institution;
  final String? photoProfilUrl;
  final DateTime? dateDerniereConnexion;
  final DateTime dateCreation;

  const ProfilEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.telephone,
    required this.fonction,
    required this.laboratoire,
    required this.institution,
    this.photoProfilUrl,
    this.dateDerniereConnexion,
    required this.dateCreation,
  });

  bool get estAdministrateur => role == 'administrateur';

  /// Initiales pour l'avatar (2 lettres max), calculées depuis le nom
  /// complet — jamais une valeur en dur.
  String get initiales {
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    if (mots.length == 1) return mots.first.substring(0, 1).toUpperCase();
    return (mots.first.substring(0, 1) + mots.last.substring(0, 1)).toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        email,
        role,
        telephone,
        fonction,
        laboratoire,
        institution,
        photoProfilUrl,
        dateDerniereConnexion,
        dateCreation,
      ];
}
