import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/historique_repository.dart';

class DeclencherExportUseCase implements UseCase<void, String> {
  final HistoriqueRepository repository;

  const DeclencherExportUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String format) {
    return repository.declencherExport(format);
  }
}
