import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/confirmer_reset_mot_de_passe_usecase.dart';

/// Étape 3/3 du parcours « mot de passe oublié » : confirmation avec le
/// nouveau mot de passe.
class ConfirmerResetState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final bool reinitialisationReussie;

  const ConfirmerResetState({
    this.enChargement = false,
    this.echec,
    this.reinitialisationReussie = false,
  });

  ConfirmerResetState copierAvec({
    bool? enChargement,
    Failure? echec,
    bool? reinitialisationReussie,
    bool effacerErreur = false,
  }) {
    return ConfirmerResetState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      reinitialisationReussie: reinitialisationReussie ?? this.reinitialisationReussie,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, reinitialisationReussie];
}

class ConfirmerResetNotifier extends StateNotifier<ConfirmerResetState> {
  final ConfirmerResetMotDePasseUseCase _useCase;

  ConfirmerResetNotifier(this._useCase) : super(const ConfirmerResetState());

  Future<void> confirmer({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  }) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final resultat = await _useCase(
      ConfirmerResetMotDePasseParams(
        email: email,
        code: code,
        nouveauMotDePasse: nouveauMotDePasse,
      ),
    );

    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        echec: failure,
      ),
      (_) => state = state.copierAvec(enChargement: false, reinitialisationReussie: true),
    );
  }
}

final confirmerResetProvider =
    StateNotifierProvider.autoDispose<ConfirmerResetNotifier, ConfirmerResetState>(
  (ref) => ConfirmerResetNotifier(sl<ConfirmerResetMotDePasseUseCase>()),
);
