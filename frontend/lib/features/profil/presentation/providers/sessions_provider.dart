import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/lister_sessions_usecase.dart';
import '../../domain/usecases/revoquer_session_usecase.dart';

class SessionsState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final List<SessionEntity>? sessions;
  final Set<int> enCoursDeRevocation;

  const SessionsState({
    this.enChargement = false,
    this.echec,
    this.sessions,
    this.enCoursDeRevocation = const {},
  });

  SessionsState copierAvec({
    bool? enChargement,
    Failure? echec,
    List<SessionEntity>? sessions,
    Set<int>? enCoursDeRevocation,
    bool effacerErreur = false,
  }) {
    return SessionsState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      sessions: sessions ?? this.sessions,
      enCoursDeRevocation: enCoursDeRevocation ?? this.enCoursDeRevocation,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, sessions, enCoursDeRevocation];
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  final ListerSessionsUseCase _listerSessionsUseCase;
  final RevoquerSessionUseCase _revoquerSessionUseCase;

  SessionsNotifier(this._listerSessionsUseCase, this._revoquerSessionUseCase)
      : super(const SessionsState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _listerSessionsUseCase(const NoParams());
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (sessions) => state = state.copierAvec(enChargement: false, sessions: sessions),
    );
  }

  Future<void> revoquer(int id) async {
    state = state.copierAvec(enCoursDeRevocation: {...state.enCoursDeRevocation, id});
    final resultat = await _revoquerSessionUseCase(id);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(
        enCoursDeRevocation: {...state.enCoursDeRevocation}..remove(id),
        echec: failure,
      ),
      (_) => state = state.copierAvec(
        enCoursDeRevocation: {...state.enCoursDeRevocation}..remove(id),
        sessions: state.sessions?.where((session) => session.id != id).toList(),
      ),
    );
  }

  /// Révoque toutes les sessions sauf la session courante (identifiée côté
  /// backend via le jti transmis à la lecture — voir
  /// ProfilRepositoryImpl.listerSessions).
  Future<void> revoquerToutesSaufCourante() async {
    final autres = (state.sessions ?? const [])
        .where((session) => !session.estCourante)
        .map((session) => session.id);
    for (final id in autres) {
      await revoquer(id);
    }
  }
}

final sessionsProvider = StateNotifierProvider.autoDispose<SessionsNotifier, SessionsState>(
  (ref) => SessionsNotifier(sl<ListerSessionsUseCase>(), sl<RevoquerSessionUseCase>()),
);
