import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/modele_entity.dart';

abstract class ModelesRepository {
  Future<Either<Failure, List<ModeleEntity>>> listerModeles();
}
