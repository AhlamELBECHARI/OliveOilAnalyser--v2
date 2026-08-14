import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/administration_repository.dart';

class ListerJournalAuditUseCase implements UseCase<PageJournalAudit, int> {
  final AdministrationRepository repository;

  const ListerJournalAuditUseCase(this.repository);

  @override
  Future<Either<Failure, PageJournalAudit>> call(int page) {
    return repository.listerJournalAudit(page: page);
  }
}
