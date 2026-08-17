import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/cache_local_service.dart';
import '../../domain/entities/modele_entity.dart';
import '../../domain/repositories/modeles_repository.dart';
import '../datasources/modeles_remote_datasource.dart';
import '../models/modele_model.dart';

class ModelesRepositoryImpl implements ModelesRepository {
  final ModelesRemoteDataSource remoteDataSource;
  final CacheLocalService cacheLocal;

  const ModelesRepositoryImpl({required this.remoteDataSource, required this.cacheLocal});

  /// Lecture-first hors ligne : les modèles actifs doivent rester
  /// disponibles sans réseau pour que le calcul de conformité pendant une
  /// analyse reste possible (cahier des charges, Partie A, section 4). Seuls
  /// les modèles actifs sont mis en cache — les autres n'ont aucun usage
  /// hors ligne (pas de scoring, pas de gestion CRUD possible sans réseau).
  @override
  Future<Either<Failure, List<ModeleEntity>>> listerModeles() async {
    try {
      final modeles = await remoteDataSource.listerModeles();
      await cacheLocal.ecrireListe(
        CleCache.modelesActifs,
        modeles.where((m) => m.estActif).map((m) => m.toJson()).toList(),
      );
      return Right(modeles);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      final cache = await cacheLocal.lireListe(CleCache.modelesActifs);
      if (cache != null) {
        return Right(cache.map(ModeleModel.fromJson).toList());
      }
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
