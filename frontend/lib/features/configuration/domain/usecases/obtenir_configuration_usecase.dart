import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/configuration_entity.dart';
import '../repositories/configuration_repository.dart';

class ObtenirConfigurationUseCase implements UseCase<ConfigurationEntity, NoParams> {
  final ConfigurationRepository repository;

  const ObtenirConfigurationUseCase(this.repository);

  @override
  Future<Either<Failure, ConfigurationEntity>> call(NoParams params) {
    return repository.obtenirConfiguration();
  }
}
