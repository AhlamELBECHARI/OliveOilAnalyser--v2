import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/changer_mot_de_passe_usecase.dart';

class ChangerMotDePasseState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final bool succes;

  const ChangerMotDePasseState({this.enChargement = false, this.echec, this.succes = false});

  ChangerMotDePasseState copierAvec({
    bool? enChargement,
    Failure? echec,
    bool? succes,
    bool effacerErreur = false,
  }) {
    return ChangerMotDePasseState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      succes: succes ?? this.succes,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, succes];
}

class ChangerMotDePasseNotifier extends StateNotifier<ChangerMotDePasseState> {
  final ChangerMotDePasseUseCase _useCase;

  ChangerMotDePasseNotifier(this._useCase) : super(const ChangerMotDePasseState());

  Future<void> changer({required String ancien, required String nouveau}) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _useCase(
      ChangerMotDePasseParams(ancienMotDePasse: ancien, nouveauMotDePasse: nouveau),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (_) => state = state.copierAvec(enChargement: false, succes: true),
    );
  }
}

final changerMotDePasseProvider =
    StateNotifierProvider.autoDispose<ChangerMotDePasseNotifier, ChangerMotDePasseState>(
  (ref) => ChangerMotDePasseNotifier(sl<ChangerMotDePasseUseCase>()),
);
