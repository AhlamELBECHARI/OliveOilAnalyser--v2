import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parametres_repository.dart';

class DefinirLocaleParams extends Equatable {
  final Locale locale;

  const DefinirLocaleParams({required this.locale});

  @override
  List<Object?> get props => [locale];
}

class DefinirLocaleUseCase implements UseCase<Unit, DefinirLocaleParams> {
  final ParametresRepository repository;

  const DefinirLocaleUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DefinirLocaleParams params) async {
    await repository.definirLocale(params.locale);
    return const Right(unit);
  }
}
