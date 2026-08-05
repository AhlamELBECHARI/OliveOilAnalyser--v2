import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ConfirmerResetMotDePasseParams extends Equatable {
  final String email;
  final String code;
  final String nouveauMotDePasse;

  const ConfirmerResetMotDePasseParams({
    required this.email,
    required this.code,
    required this.nouveauMotDePasse,
  });

  @override
  List<Object?> get props => [email, code, nouveauMotDePasse];
}

class ConfirmerResetMotDePasseUseCase
    implements UseCase<Unit, ConfirmerResetMotDePasseParams> {
  final AuthRepository repository;

  const ConfirmerResetMotDePasseUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ConfirmerResetMotDePasseParams params) {
    return repository.confirmerResetMotDePasse(
      email: params.email,
      code: params.code,
      nouveauMotDePasse: params.nouveauMotDePasse,
    );
  }
}
