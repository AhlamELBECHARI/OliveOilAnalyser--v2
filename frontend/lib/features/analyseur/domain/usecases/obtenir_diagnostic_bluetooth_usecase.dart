import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/diagnostic_bluetooth_entity.dart';
import '../repositories/analyseur_repository.dart';

class ObtenirDiagnosticBluetoothUseCase implements UseCase<DiagnosticBluetoothEntity, NoParams> {
  final AnalyseurRepository repository;

  const ObtenirDiagnosticBluetoothUseCase(this.repository);

  @override
  Future<Either<Failure, DiagnosticBluetoothEntity>> call(NoParams params) async {
    return Right(await repository.obtenirDiagnostic());
  }
}
