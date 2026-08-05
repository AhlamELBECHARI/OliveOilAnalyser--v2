import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/etat_analyseur_entity.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../domain/usecases/compter_alertes_non_resolues_usecase.dart';
import '../../domain/usecases/obtenir_etat_analyseur_usecase.dart';
import '../../domain/usecases/obtenir_statistiques_usecase.dart';

class DashboardState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final StatistiquesDashboardEntity? statistiques;
  final int alertesNonLues;
  final EtatAnalyseurEntity? etatAnalyseur;

  const DashboardState({
    this.enChargement = false,
    this.echec,
    this.statistiques,
    this.alertesNonLues = 0,
    this.etatAnalyseur,
  });

  DashboardState copierAvec({
    bool? enChargement,
    Failure? echec,
    StatistiquesDashboardEntity? statistiques,
    int? alertesNonLues,
    EtatAnalyseurEntity? etatAnalyseur,
    bool effacerErreur = false,
  }) {
    return DashboardState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      statistiques: statistiques ?? this.statistiques,
      alertesNonLues: alertesNonLues ?? this.alertesNonLues,
      etatAnalyseur: etatAnalyseur ?? this.etatAnalyseur,
    );
  }

  @override
  List<Object?> get props =>
      [enChargement, echec, statistiques, alertesNonLues, etatAnalyseur];
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ObtenirStatistiquesUseCase _statsUseCase;
  final CompterAlertesNonResoluesUseCase _alertesUseCase;
  final ObtenirEtatAnalyseurUseCase _etatUseCase;

  DashboardNotifier(this._statsUseCase, this._alertesUseCase, this._etatUseCase)
      : super(const DashboardState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);

    final statsFuture = _statsUseCase(const NoParams());
    final alertesFuture = _alertesUseCase(const NoParams());
    final etatFuture = _etatUseCase(const NoParams());

    final statsResultat = await statsFuture;
    final alertesResultat = await alertesFuture;
    final etatResultat = await etatFuture;

    statsResultat.fold(
      (failure) => state = state.copierAvec(
        enChargement: false,
        echec: failure,
      ),
      (statistiques) => state = state.copierAvec(
        enChargement: false,
        statistiques: statistiques,
        alertesNonLues: alertesResultat.getOrElse(() => 0),
        etatAnalyseur: etatResultat.fold((_) => state.etatAnalyseur, (etat) => etat),
      ),
    );
  }
}

final dashboardProvider = StateNotifierProvider.autoDispose<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(
    sl<ObtenirStatistiquesUseCase>(),
    sl<CompterAlertesNonResoluesUseCase>(),
    sl<ObtenirEtatAnalyseurUseCase>(),
  ),
);
