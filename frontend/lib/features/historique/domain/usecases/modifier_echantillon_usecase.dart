import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/historique_repository.dart';

class ModifierEchantillonParams extends Equatable {
  final String echantillonId;
  final String producteur;
  final String variete;
  final String region;

  const ModifierEchantillonParams({
    required this.echantillonId,
    required this.producteur,
    required this.variete,
    required this.region,
  });

  @override
  List<Object?> get props => [echantillonId, producteur, variete, region];
}

class ModifierEchantillonUseCase implements UseCase<void, ModifierEchantillonParams> {
  final HistoriqueRepository repository;

  const ModifierEchantillonUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ModifierEchantillonParams params) {
    return repository.modifierEchantillon(
      echantillonId: params.echantillonId,
      producteur: params.producteur,
      variete: params.variete,
      region: params.region,
    );
  }
}
