import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/configuration_entity.dart';

abstract class ConfigurationRepository {
  Future<Either<Failure, ConfigurationEntity>> obtenirConfiguration();

  /// PUT /api/configuration/ attend l'objet complet (pas de mise à jour
  /// partielle côté backend) : l'appelant doit donc toujours fournir la
  /// configuration entière, seuils inclus, même pour ne changer qu'un seul
  /// champ (ex. notifications_actives). Échoue avec une Failure de
  /// permission pour un utilisateur non administrateur (403 côté API).
  Future<Either<Failure, ConfigurationEntity>> modifierConfiguration(
    ConfigurationEntity configuration,
  );
}
