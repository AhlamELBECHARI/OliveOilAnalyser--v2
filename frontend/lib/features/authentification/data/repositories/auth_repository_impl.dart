import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthSessionEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final reponse = await remoteDataSource.login(
        email: email,
        password: password,
      );
      final session = reponse.versEntity();
      await localDataSource.enregistrerSession(
        accessToken: reponse.access,
        refreshToken: reponse.refresh,
        role: session.utilisateur.role,
      );
      return Right(session);
    } on IdentifiantsInvalidesException {
      return const Left(IdentifiantsInvalidesFailure());
    } on CompteVerrouilleException {
      return const Left(CompteVerrouilleFailure());
    } on CompteDesactiveException {
      return const Left(CompteDesactiveFailure());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } on ErreurReseauException {
      return const Left(ErreurReseauFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> demanderResetMotDePasse({
    required String email,
  }) async {
    try {
      await remoteDataSource.demanderResetMotDePasse(email: email);
      return const Right(unit);
    } on TropDeDemandesException {
      return const Left(TropDeDemandesFailure());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> verifierCodeReset({
    required String email,
    required String code,
  }) async {
    try {
      await remoteDataSource.verifierCodeReset(email: email, code: code);
      return const Right(unit);
    } on CodeResetInvalideException {
      return const Left(CodeResetInvalideFailure());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmerResetMotDePasse({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  }) async {
    try {
      await remoteDataSource.confirmerResetMotDePasse(
        email: email,
        code: code,
        nouveauMotDePasse: nouveauMotDePasse,
      );
      return const Right(unit);
    } on CodeResetInvalideException {
      return const Left(CodeResetInvalideFailure());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<bool> possedeSessionLocale() => localDataSource.possedeSessionLocale();

  @override
  Future<String?> obtenirRoleSession() => localDataSource.obtenirRoleSession();

  @override
  Future<void> deconnecter() => localDataSource.supprimerSession();
}
