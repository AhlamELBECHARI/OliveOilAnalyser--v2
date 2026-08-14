import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../profil/domain/entities/session_entity.dart';
import '../../domain/entities/utilisateur_admin_entity.dart';
import '../../domain/repositories/utilisateurs_admin_repository.dart';
import '../datasources/utilisateurs_admin_remote_datasource.dart';

class UtilisateursAdminRepositoryImpl implements UtilisateursAdminRepository {
  final UtilisateursAdminRemoteDataSource remoteDataSource;

  const UtilisateursAdminRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _executer<T>(Future<T> Function() appel) async {
    try {
      return Right(await appel());
    } on AutoModificationInterditeException {
      return const Left(AutoModificationInterditeFailure());
    } on DernierAdministrateurException {
      return const Left(DernierAdministrateurFailure());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, PageUtilisateursAdmin>> listerUtilisateurs({
    required int page,
    String? recherche,
    String? role,
    bool? actif,
    bool? verrouille,
  }) {
    return _executer(() async {
      final resultat = await remoteDataSource.listerUtilisateurs(
        page: page,
        recherche: recherche,
        role: role,
        actif: actif,
        verrouille: verrouille,
      );
      return PageUtilisateursAdmin(
        utilisateurs: resultat.utilisateurs,
        aPageSuivante: resultat.aPageSuivante,
        total: resultat.total,
      );
    });
  }

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> obtenirUtilisateur(int id) {
    return _executer(() => remoteDataSource.obtenirUtilisateur(id));
  }

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> creerUtilisateur({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) {
    return _executer(
      () => remoteDataSource.creerUtilisateur(nom: nom, email: email, password: password, role: role),
    );
  }

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> changerRole(int id, String role) {
    return _executer(() => remoteDataSource.changerRole(id, role));
  }

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> definirActivation(int id, bool actif) {
    return _executer(() => remoteDataSource.definirActivation(id, actif));
  }

  @override
  Future<Either<Failure, UtilisateurAdminEntity>> deverrouiller(int id) {
    return _executer(() => remoteDataSource.deverrouiller(id));
  }

  @override
  Future<Either<Failure, void>> declencherResetMotDePasse(int id) {
    return _executer(() => remoteDataSource.declencherResetMotDePasse(id));
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> listerSessions(int id) {
    return _executer(() => remoteDataSource.listerSessions(id));
  }

  @override
  Future<Either<Failure, void>> revoquerSession(int utilisateurId, int sessionId) {
    return _executer(() => remoteDataSource.revoquerSession(utilisateurId, sessionId));
  }
}
