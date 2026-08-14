import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/journal_audit_entity.dart';
import '../../domain/usecases/lister_journal_audit_usecase.dart';

class JournalAuditState extends Equatable {
  final bool enChargement;
  final bool chargementPageSuivante;
  final Failure? echec;
  final List<JournalAuditEntity>? entrees;
  final bool aPageSuivante;
  final int page;

  const JournalAuditState({
    this.enChargement = false,
    this.chargementPageSuivante = false,
    this.echec,
    this.entrees,
    this.aPageSuivante = false,
    this.page = 1,
  });

  JournalAuditState copierAvec({
    bool? enChargement,
    bool? chargementPageSuivante,
    Failure? echec,
    List<JournalAuditEntity>? entrees,
    bool? aPageSuivante,
    int? page,
    bool effacerErreur = false,
  }) {
    return JournalAuditState(
      enChargement: enChargement ?? this.enChargement,
      chargementPageSuivante: chargementPageSuivante ?? this.chargementPageSuivante,
      echec: effacerErreur ? null : (echec ?? this.echec),
      entrees: entrees ?? this.entrees,
      aPageSuivante: aPageSuivante ?? this.aPageSuivante,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props =>
      [enChargement, chargementPageSuivante, echec, entrees, aPageSuivante, page];
}

class JournalAuditNotifier extends StateNotifier<JournalAuditState> {
  final ListerJournalAuditUseCase _listerJournalAudit;

  JournalAuditNotifier(this._listerJournalAudit) : super(const JournalAuditState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true, page: 1);
    final resultat = await _listerJournalAudit(1);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (page) => state = state.copierAvec(
        enChargement: false,
        entrees: page.entrees,
        aPageSuivante: page.aPageSuivante,
      ),
    );
  }

  Future<void> chargerPageSuivante() async {
    if (!state.aPageSuivante || state.chargementPageSuivante) return;
    state = state.copierAvec(chargementPageSuivante: true);
    final pageSuivante = state.page + 1;
    final resultat = await _listerJournalAudit(pageSuivante);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(chargementPageSuivante: false, echec: failure),
      (page) => state = state.copierAvec(
        chargementPageSuivante: false,
        page: pageSuivante,
        entrees: [...?state.entrees, ...page.entrees],
        aPageSuivante: page.aPageSuivante,
      ),
    );
  }
}

final journalAuditProvider =
    StateNotifierProvider.autoDispose<JournalAuditNotifier, JournalAuditState>(
  (ref) => JournalAuditNotifier(sl<ListerJournalAuditUseCase>()),
);
