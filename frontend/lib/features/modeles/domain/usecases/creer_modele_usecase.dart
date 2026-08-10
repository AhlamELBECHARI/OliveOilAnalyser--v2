import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/modele_entity.dart';
import '../repositories/modeles_repository.dart';

class CreerModeleParams extends Equatable {
  final String nom;
  final String version;
  final String algorithme;
  final Map<String, dynamic> hyperparametres;
  final double r2;
  final double rmsecv;
  final DateTime? dateEntrainement;

  const CreerModeleParams({
    required this.nom,
    required this.version,
    required this.algorithme,
    required this.hyperparametres,
    required this.r2,
    required this.rmsecv,
    this.dateEntrainement,
  });

  @override
  List<Object?> get props =>
      [nom, version, algorithme, hyperparametres, r2, rmsecv, dateEntrainement];
}

class CreerModeleUseCase implements UseCase<ModeleEntity, CreerModeleParams> {
  final ModelesRepository repository;

  const CreerModeleUseCase(this.repository);

  @override
  Future<Either<Failure, ModeleEntity>> call(CreerModeleParams params) {
    return repository.creerModele(
      nom: params.nom,
      version: params.version,
      algorithme: params.algorithme,
      hyperparametres: params.hyperparametres,
      r2: params.r2,
      rmsecv: params.rmsecv,
      dateEntrainement: params.dateEntrainement,
    );
  }
}
