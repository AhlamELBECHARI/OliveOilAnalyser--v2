import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/nouvel_echantillon_entity.dart';
import '../repositories/nouvelle_analyse_repository.dart';

class EnregistrerEchantillonUseCase implements UseCase<void, NouvelEchantillonEntity> {
  final NouvelleAnalyseRepository repository;

  const EnregistrerEchantillonUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NouvelEchantillonEntity params) {
    return repository.enregistrerEchantillon(params);
  }
}
