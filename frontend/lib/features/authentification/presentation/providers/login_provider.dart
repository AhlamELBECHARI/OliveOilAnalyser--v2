import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/utilisateur_entity.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final bool connexionReussie;
  // Rôle de la session qui vient de s'ouvrir, pour que l'écran de login
  // route directement vers la bonne coquille (utilisateur/admin) sans appel
  // réseau supplémentaire — voir LoginScreen.
  final UtilisateurEntity? utilisateur;

  const LoginState({
    this.enChargement = false,
    this.echec,
    this.connexionReussie = false,
    this.utilisateur,
  });

  LoginState copierAvec({
    bool? enChargement,
    Failure? echec,
    bool? connexionReussie,
    UtilisateurEntity? utilisateur,
    bool effacerErreur = false,
  }) {
    return LoginState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      connexionReussie: connexionReussie ?? this.connexionReussie,
      utilisateur: utilisateur ?? this.utilisateur,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, connexionReussie, utilisateur];
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginNotifier(this._loginUseCase) : super(const LoginState());

  Future<void> seConnecter({
    required String email,
    required String password,
  }) async {
    if (state.enChargement) return;
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final resultat = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    // Voir AlertesNotifier.charger : évite "Bad state: ... after dispose"
    // si l'écran a été fermé (provider autoDispose libéré) pendant l'appel.
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        echec: failure,
      ),
      (session) => state = state.copierAvec(
        enChargement: false,
        connexionReussie: true,
        utilisateur: session.utilisateur,
      ),
    );
  }
}

final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(sl<LoginUseCase>()),
);
