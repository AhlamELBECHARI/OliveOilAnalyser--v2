import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/modele_entity.dart';
import '../../domain/repositories/modeles_repository.dart';
import '../datasources/modeles_remote_datasource.dart';

class ModelesRepositoryImpl implements ModelesRepository {
  final ModelesRemoteDataSource remoteDataSource;

  const ModelesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ModeleEntity>>> listerModeles() async {
    try {
      final modeles = await remoteDataSource.listerModeles();
      return Right(modeles);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ModeleEntity>> creerModele({
    required String nom,
    required String version,
    required String algorithme,
    required Map<String, dynamic> hyperparametres,
    required double r2,
    required double rmsecv,
    DateTime? dateEntrainement,
  }) async {
    try {
      final modele = await remoteDataSource.creerModele(
        nom: nom,
        version: version,
        algorithme: algorithme,
        hyperparametres: hyperparametres,
        r2: r2,
        rmsecv: rmsecv,
        dateEntrainement: dateEntrainement,
      );
      return Right(modele);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ModeleEntity>> televerserFichierModele({
    required int modeleId,
    required String cheminFichier,
    required String nomFichier,
  }) async {
    try {
      final modele = await remoteDataSource.televerserFichierModele(
        modeleId: modeleId,
        cheminFichier: cheminFichier,
        nomFichier: nomFichier,
      );
      return Right(modele);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, ModeleEntity>> modifierStatutModele({
    required int modeleId,
    bool? estActif,
    bool? estDeprecie,
  }) async {
    try {
      final modele = await remoteDataSource.modifierStatutModele(
        modeleId: modeleId,
        estActif: estActif,
        estDeprecie: estDeprecie,
      );
      return Right(modele);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
