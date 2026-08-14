import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/resultat_a_creer_entity.dart';
import '../repositories/nouvelle_analyse_repository.dart';

class EnregistrerResultatParams extends Equatable {
  final String resultatId;
  final String echantillonId;
  final ResultatACreerEntity resultat;

  const EnregistrerResultatParams({
    required this.resultatId,
    required this.echantillonId,
    required this.resultat,
  });

  @override
  List<Object?> get props => [resultatId, echantillonId, resultat];
}

class EnregistrerResultatUseCase implements UseCase<void, EnregistrerResultatParams> {
  final NouvelleAnalyseRepository repository;

  const EnregistrerResultatUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(EnregistrerResultatParams params) {
    return repository.enregistrerResultat(
      resultatId: params.resultatId,
      echantillonId: params.echantillonId,
      resultat: params.resultat,
    );
  }
}
