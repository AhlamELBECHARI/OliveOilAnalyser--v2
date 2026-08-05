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
}
