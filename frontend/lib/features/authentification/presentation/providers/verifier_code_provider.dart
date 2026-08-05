import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/verifier_code_reset_usecase.dart';

/// Étape 2/3 du parcours « mot de passe oublié » : vérification du code à
/// 6 chiffres avant de laisser saisir un nouveau mot de passe.
class VerifierCodeState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final bool codeValide;

  const VerifierCodeState({
    this.enChargement = false,
    this.echec,
    this.codeValide = false,
  });

  VerifierCodeState copierAvec({
    bool? enChargement,
    Failure? echec,
    bool? codeValide,
    bool effacerErreur = false,
  }) {
    return VerifierCodeState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      codeValide: codeValide ?? this.codeValide,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, codeValide];
}

class VerifierCodeNotifier extends StateNotifier<VerifierCodeState> {
  final VerifierCodeResetUseCase _useCase;

  VerifierCodeNotifier(this._useCase) : super(const VerifierCodeState());

  Future<void> verifier({required String email, required String code}) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final resultat = await _useCase(VerifierCodeResetParams(email: email, code: code));

    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        echec: failure,
      ),
      (_) => state = state.copierAvec(enChargement: false, codeValide: true),
    );
  }
}

final verifierCodeProvider =
    StateNotifierProvider.autoDispose<VerifierCodeNotifier, VerifierCodeState>(
  (ref) => VerifierCodeNotifier(sl<VerifierCodeResetUseCase>()),
);
