import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/configuration_entity.dart';
import '../repositories/configuration_repository.dart';

class ModifierConfigurationUseCase
    implements UseCase<ConfigurationEntity, ConfigurationEntity> {
  final ConfigurationRepository repository;

  const ModifierConfigurationUseCase(this.repository);

  @override
  Future<Either<Failure, ConfigurationEntity>> call(ConfigurationEntity params) {
    return repository.modifierConfiguration(params);
  }
}
