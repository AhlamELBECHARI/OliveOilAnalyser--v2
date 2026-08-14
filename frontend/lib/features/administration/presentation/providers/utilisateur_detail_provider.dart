import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../profil/domain/entities/session_entity.dart';
import '../../domain/entities/utilisateur_admin_entity.dart';
import '../../domain/usecases/changer_role_admin_usecase.dart';
import '../../domain/usecases/declencher_reset_mot_de_passe_admin_usecase.dart';
import '../../domain/usecases/definir_activation_admin_usecase.dart';
import '../../domain/usecases/deverrouiller_admin_usecase.dart';
import '../../domain/usecases/lister_sessions_admin_usecase.dart';
import '../../domain/usecases/obtenir_utilisateur_admin_usecase.dart';
import '../../domain/usecases/revoquer_session_admin_usecase.dart';

class UtilisateurDetailState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final UtilisateurAdminEntity? utilisateur;
  final bool actionEnCours;
  final Failure? echecAction;
  final List<SessionEntity>? sessions;
  final Set<int> sessionsEnCoursDeRevocation;
  final bool resetDeclenche;

  const UtilisateurDetailState({
    this.enChargement = false,
    this.echec,
    this.utilisateur,
    this.actionEnCours = false,
    this.echecAction,
    this.sessions,
    this.sessionsEnCoursDeRevocation = const {},
    this.resetDeclenche = false,
  });

  UtilisateurDetailState copierAvec({
    bool? enChargement,
    Failure? echec,
    UtilisateurAdminEntity? utilisateur,
    bool? actionEnCours,
    Failure? echecAction,
    List<SessionEntity>? sessions,
    Set<int>? sessionsEnCoursDeRevocation,
    bool? resetDeclenche,
    bool effacerErreur = false,
    bool effacerErreurAction = false,
  }) {
    return UtilisateurDetailState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      utilisateur: utilisateur ?? this.utilisateur,
      actionEnCours: actionEnCours ?? this.actionEnCours,
      echecAction: effacerErreurAction ? null : (echecAction ?? this.echecAction),
      sessions: sessions ?? this.sessions,
      sessionsEnCoursDeRevocation: sessionsEnCoursDeRevocation ?? this.sessionsEnCoursDeRevocation,
      resetDeclenche: resetDeclenche ?? this.resetDeclenche,
    );
  }

  @override
  List<Object?> get props => [
        enChargement,
        echec,
        utilisateur,
        actionEnCours,
        echecAction,
        sessions,
        sessionsEnCoursDeRevocation,
        resetDeclenche,
      ];
}

class UtilisateurDetailNotifier extends StateNotifier<UtilisateurDetailState> {
  final ObtenirUtilisateurAdminUseCase _obtenirUtilisateur;
  final ChangerRoleAdminUseCase _changerRole;
  final DefinirActivationAdminUseCase _definirActivation;
  final DeverrouillerAdminUseCase _deverrouiller;
  final DeclencherResetMotDePasseAdminUseCase _declencherReset;
  final ListerSessionsAdminUseCase _listerSessions;
  final RevoquerSessionAdminUseCase _revoquerSession;
  final int utilisateurId;

  UtilisateurDetailNotifier(
    this._obtenirUtilisateur,
    this._changerRole,
    this._definirActivation,
    this._deverrouiller,
    this._declencherReset,
    this._listerSessions,
    this._revoquerSession,
    this.utilisateurId,
  ) : super(const UtilisateurDetailState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirUtilisateur(utilisateurId);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (utilisateur) => state = state.copierAvec(enChargement: false, utilisateur: utilisateur),
    );
    unawaited(chargerSessions());
  }

  Future<void> chargerSessions() async {
    final resultat = await _listerSessions(utilisateurId);
    if (!mounted) return;
    resultat.fold((_) {}, (sessions) => state = state.copierAvec(sessions: sessions));
  }

  Future<void> changerRole(String role) async {
    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _changerRole(
      ChangerRoleAdminParams(utilisateurId: utilisateurId, role: role),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (utilisateur) => state = state.copierAvec(actionEnCours: false, utilisateur: utilisateur),
    );
  }

  Future<void> definirActivation(bool actif) async {
    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _definirActivation(
      DefinirActivationAdminParams(utilisateurId: utilisateurId, actif: actif),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (utilisateur) => state = state.copierAvec(actionEnCours: false, utilisateur: utilisateur),
    );
  }

  Future<void> deverrouiller() async {
    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _deverrouiller(utilisateurId);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (utilisateur) => state = state.copierAvec(actionEnCours: false, utilisateur: utilisateur),
    );
  }

  Future<void> declencherResetMotDePasse() async {
    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _declencherReset(utilisateurId);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (_) => state = state.copierAvec(actionEnCours: false, resetDeclenche: true),
    );
  }

  Future<void> revoquerSession(int sessionId) async {
    state = state.copierAvec(
      sessionsEnCoursDeRevocation: {...state.sessionsEnCoursDeRevocation, sessionId},
    );
    final resultat = await _revoquerSession(
      RevoquerSessionAdminParams(utilisateurId: utilisateurId, sessionId: sessionId),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(
        echecAction: failure,
        sessionsEnCoursDeRevocation: {...state.sessionsEnCoursDeRevocation}..remove(sessionId),
      ),
      (_) {
        state = state.copierAvec(
          sessions: state.sessions?.where((s) => s.id != sessionId).toList(),
          sessionsEnCoursDeRevocation: {...state.sessionsEnCoursDeRevocation}..remove(sessionId),
        );
      },
    );
  }
}

final utilisateurDetailProvider = StateNotifierProvider.autoDispose
    .family<UtilisateurDetailNotifier, UtilisateurDetailState, int>(
  (ref, utilisateurId) => UtilisateurDetailNotifier(
    sl<ObtenirUtilisateurAdminUseCase>(),
    sl<ChangerRoleAdminUseCase>(),
    sl<DefinirActivationAdminUseCase>(),
    sl<DeverrouillerAdminUseCase>(),
    sl<DeclencherResetMotDePasseAdminUseCase>(),
    sl<ListerSessionsAdminUseCase>(),
    sl<RevoquerSessionAdminUseCase>(),
    utilisateurId,
  ),
);
