import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../profil/domain/entities/session_entity.dart';
import '../entities/utilisateur_admin_entity.dart';

class PageUtilisateursAdmin {
  final List<UtilisateurAdminEntity> utilisateurs;
  final bool aPageSuivante;
  final int total;

  const PageUtilisateursAdmin({
    required this.utilisateurs,
    required this.aPageSuivante,
    required this.total,
  });
}

abstract class UtilisateursAdminRepository {
  Future<Either<Failure, PageUtilisateursAdmin>> listerUtilisateurs({
    required int page,
    String? recherche,
    String? role,
    bool? actif,
    bool? verrouille,
  });
  Future<Either<Failure, UtilisateurAdminEntity>> obtenirUtilisateur(int id);
  Future<Either<Failure, UtilisateurAdminEntity>> creerUtilisateur({
    required String nom,
    required String email,
    required String password,
    required String role,
  });
  Future<Either<Failure, UtilisateurAdminEntity>> changerRole(int id, String role);
  Future<Either<Failure, UtilisateurAdminEntity>> definirActivation(int id, bool actif);
  Future<Either<Failure, UtilisateurAdminEntity>> deverrouiller(int id);
  Future<Either<Failure, void>> declencherResetMotDePasse(int id);
  Future<Either<Failure, List<SessionEntity>>> listerSessions(int id);
  Future<Either<Failure, void>> revoquerSession(int utilisateurId, int sessionId);
}
