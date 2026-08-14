import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSessionEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> demanderResetMotDePasse({
    required String email,
  });

  Future<Either<Failure, Unit>> verifierCodeReset({
    required String email,
    required String code,
  });

  Future<Either<Failure, Unit>> confirmerResetMotDePasse({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  });

  /// Vrai si une session (refresh token) est déjà stockée localement.
  /// Ne fait aucun appel réseau : la validité réelle du refresh token n'est
  /// vérifiée qu'au premier appel authentifié (voir core/network/AuthInterceptor).
  Future<bool> possedeSessionLocale();

  /// Rôle persisté au dernier login réussi ('utilisateur'/'administrateur'),
  /// ou `null` si aucune session — utilisé au démarrage de l'app pour
  /// choisir la coquille de navigation (utilisateur/admin) sans appel
  /// réseau (voir main.dart).
  Future<String?> obtenirRoleSession();

  Future<void> deconnecter();
}
