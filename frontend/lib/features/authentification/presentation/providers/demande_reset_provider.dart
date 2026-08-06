import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/demander_reset_mot_de_passe_usecase.dart';

/// Étape 1/3 du parcours « mot de passe oublié » : demande d'envoi du code
/// à 6 chiffres par email.
class DemandeResetState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final bool demandeEnvoyee;

  const DemandeResetState({
    this.enChargement = false,
    this.echec,
    this.demandeEnvoyee = false,
  });

  DemandeResetState copierAvec({
    bool? enChargement,
    Failure? echec,
    bool? demandeEnvoyee,
    bool effacerErreur = false,
  }) {
    return DemandeResetState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      demandeEnvoyee: demandeEnvoyee ?? this.demandeEnvoyee,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, demandeEnvoyee];
}

class DemandeResetNotifier extends StateNotifier<DemandeResetState> {
  final DemanderResetMotDePasseUseCase _useCase;

  DemandeResetNotifier(this._useCase) : super(const DemandeResetState());

  Future<void> demander({required String email}) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final resultat = await _useCase(DemanderResetMotDePasseParams(email: email));

    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        echec: failure,
      ),
      (_) => state = state.copierAvec(enChargement: false, demandeEnvoyee: true),
    );
  }

  /// Remet l'indicateur `demandeEnvoyee` à zéro pour permettre un renvoi de
  /// code depuis l'écran de saisie du code sans naviguer à nouveau.
  void reinitialiserDemandeEnvoyee() {
    state = state.copierAvec(demandeEnvoyee: false);
  }
}

final demandeResetProvider =
    StateNotifierProvider.autoDispose<DemandeResetNotifier, DemandeResetState>(
  (ref) => DemandeResetNotifier(sl<DemanderResetMotDePasseUseCase>()),
);
