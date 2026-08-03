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
      await localDataSource.enregistrerSession(
        accessToken: reponse.access,
        refreshToken: reponse.refresh,
      );
      return Right(reponse.versEntity());
    } on IdentifiantsInvalidesException {
      return const Left(IdentifiantsInvalidesFailure());
    } on CompteVerrouilleException {
      return const Left(CompteVerrouilleFailure());
    } on ErreurValidationException catch (e) {
      return Left(ErreurValidationFailure(e.message));
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
    } on ErreurValidationException catch (e) {
      return Left(ErreurValidationFailure(e.message));
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<bool> possedeSessionLocale() => localDataSource.possedeSessionLocale();

  @override
  Future<void> deconnecter() => localDataSource.supprimerSession();
}
