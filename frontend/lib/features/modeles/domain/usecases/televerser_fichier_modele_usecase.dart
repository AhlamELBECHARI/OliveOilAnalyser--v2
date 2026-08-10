import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/modele_entity.dart';
import '../repositories/modeles_repository.dart';

class TeleverserFichierModeleParams extends Equatable {
  final int modeleId;
  final String cheminFichier;
  final String nomFichier;

  const TeleverserFichierModeleParams({
    required this.modeleId,
    required this.cheminFichier,
    required this.nomFichier,
  });

  @override
  List<Object?> get props => [modeleId, cheminFichier, nomFichier];
}

class TeleverserFichierModeleUseCase
    implements UseCase<ModeleEntity, TeleverserFichierModeleParams> {
  final ModelesRepository repository;

  const TeleverserFichierModeleUseCase(this.repository);

  @override
  Future<Either<Failure, ModeleEntity>> call(TeleverserFichierModeleParams params) {
    return repository.televerserFichierModele(
      modeleId: params.modeleId,
      cheminFichier: params.cheminFichier,
      nomFichier: params.nomFichier,
    );
  }
}
