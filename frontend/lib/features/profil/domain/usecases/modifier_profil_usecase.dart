import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profil_entity.dart';
import '../repositories/profil_repository.dart';

class ModifierProfilParams extends Equatable {
  final String? nom;
  final String? telephone;
  final String? fonction;
  final String? laboratoire;
  final String? institution;

  const ModifierProfilParams({
    this.nom,
    this.telephone,
    this.fonction,
    this.laboratoire,
    this.institution,
  });

  @override
  List<Object?> get props => [nom, telephone, fonction, laboratoire, institution];
}

class ModifierProfilUseCase implements UseCase<ProfilEntity, ModifierProfilParams> {
  final ProfilRepository repository;

  const ModifierProfilUseCase(this.repository);

  @override
  Future<Either<Failure, ProfilEntity>> call(ModifierProfilParams params) {
    return repository.modifierProfil(
      nom: params.nom,
      telephone: params.telephone,
      fonction: params.fonction,
      laboratoire: params.laboratoire,
      institution: params.institution,
    );
  }
}
