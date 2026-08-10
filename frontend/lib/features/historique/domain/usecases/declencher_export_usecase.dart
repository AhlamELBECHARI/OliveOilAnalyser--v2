import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/demande_export_entity.dart';
import '../entities/rapport_export_entity.dart';
import '../repositories/historique_repository.dart';

class DeclencherExportUseCase implements UseCase<RapportExportEntity, DemandeExportEntity> {
  final HistoriqueRepository repository;

  const DeclencherExportUseCase(this.repository);

  @override
  Future<Either<Failure, RapportExportEntity>> call(DemandeExportEntity params) {
    return repository.declencherExport(params);
  }
}
