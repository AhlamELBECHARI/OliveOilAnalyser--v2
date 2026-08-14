import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/creer_utilisateur_admin_usecase.dart';

class CreationUtilisateurState extends Equatable {
  final bool enCours;
  final Failure? echec;
  final bool reussie;

  const CreationUtilisateurState({this.enCours = false, this.echec, this.reussie = false});

  CreationUtilisateurState copierAvec({
    bool? enCours,
    Failure? echec,
    bool? reussie,
    bool effacerErreur = false,
  }) {
    return CreationUtilisateurState(
      enCours: enCours ?? this.enCours,
      echec: effacerErreur ? null : (echec ?? this.echec),
      reussie: reussie ?? this.reussie,
    );
  }

  @override
  List<Object?> get props => [enCours, echec, reussie];
}

class CreationUtilisateurNotifier extends StateNotifier<CreationUtilisateurState> {
  final CreerUtilisateurAdminUseCase _creerUtilisateur;

  CreationUtilisateurNotifier(this._creerUtilisateur) : super(const CreationUtilisateurState());

  Future<void> soumettre({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copierAvec(enCours: true, effacerErreur: true);
    final resultat = await _creerUtilisateur(
      CreerUtilisateurAdminParams(nom: nom, email: email, password: password, role: role),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enCours: false, echec: failure),
      (_) => state = state.copierAvec(enCours: false, reussie: true),
    );
  }
}

final creationUtilisateurProvider = StateNotifierProvider.autoDispose<
    CreationUtilisateurNotifier, CreationUtilisateurState>(
  (ref) => CreationUtilisateurNotifier(sl<CreerUtilisateurAdminUseCase>()),
);
