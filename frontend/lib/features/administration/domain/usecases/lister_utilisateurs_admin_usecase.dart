import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/utilisateurs_admin_repository.dart';

class ListerUtilisateursAdminParams extends Equatable {
  final int page;
  final String? recherche;
  final String? role;
  final bool? actif;
  final bool? verrouille;

  const ListerUtilisateursAdminParams({
    required this.page,
    this.recherche,
    this.role,
    this.actif,
    this.verrouille,
  });

  @override
  List<Object?> get props => [page, recherche, role, actif, verrouille];
}

class ListerUtilisateursAdminUseCase
    implements UseCase<PageUtilisateursAdmin, ListerUtilisateursAdminParams> {
  final UtilisateursAdminRepository repository;

  const ListerUtilisateursAdminUseCase(this.repository);

  @override
  Future<Either<Failure, PageUtilisateursAdmin>> call(ListerUtilisateursAdminParams params) {
    return repository.listerUtilisateurs(
      page: params.page,
      recherche: params.recherche,
      role: params.role,
      actif: params.actif,
      verrouille: params.verrouille,
    );
  }
}
