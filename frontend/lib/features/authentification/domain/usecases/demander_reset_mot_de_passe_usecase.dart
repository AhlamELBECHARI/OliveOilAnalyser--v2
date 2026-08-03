import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class DemanderResetMotDePasseParams extends Equatable {
  final String email;

  const DemanderResetMotDePasseParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class DemanderResetMotDePasseUseCase
    implements UseCase<Unit, DemanderResetMotDePasseParams> {
  final AuthRepository repository;

  const DemanderResetMotDePasseUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DemanderResetMotDePasseParams params) {
    return repository.demanderResetMotDePasse(email: params.email);
  }
}
