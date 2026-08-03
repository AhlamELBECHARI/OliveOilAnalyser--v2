import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginState extends Equatable {
  final bool enChargement;
  final String? messageErreur;
  final bool connexionReussie;

  const LoginState({
    this.enChargement = false,
    this.messageErreur,
    this.connexionReussie = false,
  });

  LoginState copierAvec({
    bool? enChargement,
    String? messageErreur,
    bool? connexionReussie,
    bool effacerErreur = false,
  }) {
    return LoginState(
      enChargement: enChargement ?? this.enChargement,
      messageErreur: effacerErreur ? null : (messageErreur ?? this.messageErreur),
      connexionReussie: connexionReussie ?? this.connexionReussie,
    );
  }

  @override
  List<Object?> get props => [enChargement, messageErreur, connexionReussie];
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

    resultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        messageErreur: failure.message,
      ),
      (_) => state = state.copierAvec(
        enChargement: false,
        connexionReussie: true,
      ),
    );
  }
}

final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(sl<LoginUseCase>()),
);
