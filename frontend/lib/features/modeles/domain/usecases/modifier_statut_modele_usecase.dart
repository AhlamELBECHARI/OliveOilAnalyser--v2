import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/modele_entity.dart';
import '../repositories/modeles_repository.dart';

class ModifierStatutModeleParams extends Equatable {
  final int modeleId;
  final bool? estActif;
  final bool? estDeprecie;

  const ModifierStatutModeleParams({required this.modeleId, this.estActif, this.estDeprecie});

  @override
  List<Object?> get props => [modeleId, estActif, estDeprecie];
}

class ModifierStatutModeleUseCase implements UseCase<ModeleEntity, ModifierStatutModeleParams> {
  final ModelesRepository repository;

  const ModifierStatutModeleUseCase(this.repository);

  @override
  Future<Either<Failure, ModeleEntity>> call(ModifierStatutModeleParams params) {
    return repository.modifierStatutModele(
      modeleId: params.modeleId,
      estActif: params.estActif,
      estDeprecie: params.estDeprecie,
    );
  }
}
