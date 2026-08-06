import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../repositories/nouvelle_analyse_repository.dart';

class EnregistrerSpectreParams extends Equatable {
  final String echantillonId;
  final SpectreBrutEntity spectre;

  const EnregistrerSpectreParams({required this.echantillonId, required this.spectre});

  @override
  List<Object?> get props => [echantillonId, spectre];
}

class EnregistrerSpectreUseCase implements UseCase<void, EnregistrerSpectreParams> {
  final NouvelleAnalyseRepository repository;

  const EnregistrerSpectreUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(EnregistrerSpectreParams params) {
    return repository.enregistrerSpectre(
      echantillonId: params.echantillonId,
      spectre: params.spectre,
    );
  }
}
