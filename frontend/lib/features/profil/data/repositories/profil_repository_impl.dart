import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage_service.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/profil_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/profil_repository.dart';
import '../datasources/profil_remote_datasource.dart';

class ProfilRepositoryImpl implements ProfilRepository {
  final ProfilRemoteDataSource remoteDataSource;
  final TokenStorageService tokenStorage;

  const ProfilRepositoryImpl({required this.remoteDataSource, required this.tokenStorage});

  @override
  Future<Either<Failure, ProfilEntity>> obtenirProfil() =>
      _executer(() => remoteDataSource.obtenirProfil());

  @override
  Future<Either<Failure, ProfilEntity>> modifierProfil({
    String? nom,
    String? telephone,
    String? fonction,
    String? laboratoire,
    String? institution,
  }) {
    final champs = <String, dynamic>{
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (fonction != null) 'fonction': fonction,
      if (laboratoire != null) 'laboratoire': laboratoire,
      if (institution != null) 'institution': institution,
    };
    return _executer(() => remoteDataSource.modifierProfil(champs));
  }

  @override
  Future<Either<Failure, ProfilEntity>> televerserPhoto(XFile fichier) =>
      _executer(() => remoteDataSource.televerserPhoto(fichier));

  @override
  Future<Either<Failure, void>> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) {
    return _executer(() => remoteDataSource.changerMotDePasse(
          ancien: ancienMotDePasse,
          nouveau: nouveauMotDePasse,
        ));
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> listerSessions() async {
    final refresh = await tokenStorage.lireRefreshToken();
    final jtiCourant = refresh == null ? null : jtiDuToken(refresh);
    return _executer(() => remoteDataSource.listerSessions(jtiCourant: jtiCourant));
  }

  @override
  Future<Either<Failure, void>> revoquerSession(int id) =>
      _executer(() => remoteDataSource.revoquerSession(id));

  Future<Either<Failure, T>> _executer<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
