import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/demander_reset_mot_de_passe_usecase.dart';

class ResetPasswordState extends Equatable {
  final bool enChargement;
  final String? messageErreur;
  final bool demandeEnvoyee;

  const ResetPasswordState({
    this.enChargement = false,
    this.messageErreur,
    this.demandeEnvoyee = false,
  });

  ResetPasswordState copierAvec({
    bool? enChargement,
    String? messageErreur,
    bool? demandeEnvoyee,
    bool effacerErreur = false,
  }) {
    return ResetPasswordState(
      enChargement: enChargement ?? this.enChargement,
      messageErreur: effacerErreur ? null : (messageErreur ?? this.messageErreur),
      demandeEnvoyee: demandeEnvoyee ?? this.demandeEnvoyee,
    );
  }

  @override
  List<Object?> get props => [enChargement, messageErreur, demandeEnvoyee];
}

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final DemanderResetMotDePasseUseCase _useCase;

  ResetPasswordNotifier(this._useCase) : super(const ResetPasswordState());

  Future<void> demander({required String email}) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final resultat = await _useCase(
      DemanderResetMotDePasseParams(email: email),
    );

    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        messageErreur: failure.message,
      ),
      (_) => state = state.copierAvec(
        enChargement: false,
        demandeEnvoyee: true,
      ),
    );
  }
}

final resetPasswordProvider =
    StateNotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordState>(
  (ref) => ResetPasswordNotifier(sl<DemanderResetMotDePasseUseCase>()),
);
