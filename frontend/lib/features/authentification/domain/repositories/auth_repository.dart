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

  /// Vrai si une session (refresh token) est déjà stockée localement.
  /// Ne fait aucun appel réseau : la validité réelle du refresh token n'est
  /// vérifiée qu'au premier appel authentifié (voir core/network/AuthInterceptor).
  Future<bool> possedeSessionLocale();

  Future<void> deconnecter();
}
