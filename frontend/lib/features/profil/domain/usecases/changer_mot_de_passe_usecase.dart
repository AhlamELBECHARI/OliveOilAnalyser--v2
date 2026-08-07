import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profil_repository.dart';

class ChangerMotDePasseParams extends Equatable {
  final String ancienMotDePasse;
  final String nouveauMotDePasse;

  const ChangerMotDePasseParams({
    required this.ancienMotDePasse,
    required this.nouveauMotDePasse,
  });

  @override
  List<Object?> get props => [ancienMotDePasse, nouveauMotDePasse];
}

class ChangerMotDePasseUseCase implements UseCase<void, ChangerMotDePasseParams> {
  final ProfilRepository repository;

  const ChangerMotDePasseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangerMotDePasseParams params) {
    return repository.changerMotDePasse(
      ancienMotDePasse: params.ancienMotDePasse,
      nouveauMotDePasse: params.nouveauMotDePasse,
    );
  }
}
