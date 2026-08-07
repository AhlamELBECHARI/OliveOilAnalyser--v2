import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parametres_repository.dart';

class DefinirModeThemeUseCase implements UseCase<void, ThemeMode> {
  final ParametresRepository repository;

  const DefinirModeThemeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ThemeMode params) async {
    await repository.definirModeTheme(params);
    return const Right(null);
  }
}
