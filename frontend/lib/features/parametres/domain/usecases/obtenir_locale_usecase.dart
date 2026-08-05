import 'dart:ui';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parametres_repository.dart';

class ObtenirLocaleUseCase implements UseCase<Locale, NoParams> {
  final ParametresRepository repository;

  const ObtenirLocaleUseCase(this.repository);

  @override
  Future<Either<Failure, Locale>> call(NoParams params) async {
    return Right(await repository.obtenirLocale());
  }
}
