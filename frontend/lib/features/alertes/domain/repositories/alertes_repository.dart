import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alerte_entity.dart';

abstract class AlertesRepository {
  Future<Either<Failure, List<AlerteEntity>>> listerAlertes();
}
