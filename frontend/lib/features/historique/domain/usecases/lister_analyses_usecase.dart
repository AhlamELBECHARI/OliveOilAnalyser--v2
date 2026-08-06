import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/analyse_historique_entity.dart';
import '../repositories/historique_repository.dart';

class ListerAnalysesParams extends Equatable {
  final int page;
  final FiltresHistorique filtres;

  const ListerAnalysesParams({required this.page, this.filtres = const FiltresHistorique()});

  @override
  List<Object?> get props => [page, filtres];
}

class ListerAnalysesUseCase implements UseCase<PageAnalysesHistorique, ListerAnalysesParams> {
  final HistoriqueRepository repository;

  const ListerAnalysesUseCase(this.repository);

  @override
  Future<Either<Failure, PageAnalysesHistorique>> call(ListerAnalysesParams params) {
    return repository.listerAnalyses(page: params.page, filtres: params.filtres);
  }
}
