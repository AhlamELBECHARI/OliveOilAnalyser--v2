import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parametres_repository.dart';

class ObtenirModeThemeUseCase implements UseCase<ThemeMode, NoParams> {
  final ParametresRepository repository;

  const ObtenirModeThemeUseCase(this.repository);

  @override
  Future<Either<Failure, ThemeMode>> call(NoParams params) async {
    return Right(await repository.obtenirModeTheme());
  }
}
