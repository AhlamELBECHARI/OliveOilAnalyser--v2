import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifierCodeResetParams extends Equatable {
  final String email;
  final String code;

  const VerifierCodeResetParams({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class VerifierCodeResetUseCase implements UseCase<Unit, VerifierCodeResetParams> {
  final AuthRepository repository;

  const VerifierCodeResetUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(VerifierCodeResetParams params) {
    return repository.verifierCodeReset(email: params.email, code: params.code);
  }
}
