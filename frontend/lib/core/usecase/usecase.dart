import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contrat standard pour un UseCase de la couche Domain :
/// prend des paramètres [P] et renvoie soit un [Failure], soit un résultat [T].
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// À utiliser quand un UseCase ne prend aucun paramètre.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
