import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';
import '../../domain/usecases/declencher_export_usecase.dart';
import '../../domain/usecases/lister_analyses_usecase.dart';
import '../../domain/usecases/obtenir_statistiques_rapides_usecase.dart';

class HistoriqueState extends Equatable {
  final bool enChargement;
  final bool chargementPageSuivante;
  final Failure? echec;
  final List<AnalyseHistoriqueEntity>? analyses;
  final bool aPageSuivante;
  final int pageCourante;
  final FiltresHistorique filtres;
  final StatistiquesRapidesEntity? statistiques;

  const HistoriqueState({
    this.enChargement = false,
    this.chargementPageSuivante = false,
    this.echec,
    this.analyses,
    this.aPageSuivante = false,
    this.pageCourante = 1,
    this.filtres = const FiltresHistorique(),
    this.statistiques,
  });

  HistoriqueState copierAvec({
    bool? enChargement,
    bool? chargementPageSuivante,
    Failure? echec,
    List<AnalyseHistoriqueEntity>? analyses,
    bool? aPageSuivante,
    int? pageCourante,
    FiltresHistorique? filtres,
    StatistiquesRapidesEntity? statistiques,
    bool effacerErreur = false,
  }) {
    return HistoriqueState(
      enChargement: enChargement ?? this.enChargement,
      chargementPageSuivante: chargementPageSuivante ?? this.chargementPageSuivante,
      echec: effacerErreur ? null : (echec ?? this.echec),
      analyses: analyses ?? this.analyses,
      aPageSuivante: aPageSuivante ?? this.aPageSuivante,
      pageCourante: pageCourante ?? this.pageCourante,
      filtres: filtres ?? this.filtres,
      statistiques: statistiques ?? this.statistiques,
    );
  }

  @override
  List<Object?> get props => [
        enChargement,
        chargementPageSuivante,
        echec,
        analyses,
        aPageSuivante,
        pageCourante,
        filtres,
        statistiques,
      ];
}

class HistoriqueNotifier extends StateNotifier<HistoriqueState> {
  final ListerAnalysesUseCase _listerAnalyses;
  final ObtenirStatistiquesRapidesUseCase _obtenirStatistiquesRapides;
  final DeclencherExportUseCase _declencherExport;

  HistoriqueNotifier(this._listerAnalyses, this._obtenirStatistiquesRapides, this._declencherExport)
      : super(const HistoriqueState()) {
    charger();
  }

  Future<Either<Failure, void>> exporter(String format) => _declencherExport(format);

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true, pageCourante: 1);

    final statsFuture = _obtenirStatistiquesRapides(const NoParams());
    final analysesFuture = _listerAnalyses(
      ListerAnalysesParams(page: 1, filtres: state.filtres),
    );

    final statsResultat = await statsFuture;
    final analysesResultat = await analysesFuture;

    // Voir AlertesNotifier.charger : évite "Bad state: ... after dispose"
    // si l'écran a été fermé (provider autoDispose libéré) pendant l'appel.
    if (!mounted) return;
    analysesResultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (page) => state = state.copierAvec(
        enChargement: false,
        analyses: page.analyses,
        aPageSuivante: page.aPageSuivante,
        statistiques: statsResultat.fold((_) => state.statistiques, (s) => s),
      ),
    );
  }

  Future<void> chargerPageSuivante() async {
    if (!state.aPageSuivante || state.chargementPageSuivante) return;
    state = state.copierAvec(chargementPageSuivante: true);

    final pageSuivante = state.pageCourante + 1;
    final resultat = await _listerAnalyses(
      ListerAnalysesParams(page: pageSuivante, filtres: state.filtres),
    );
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(chargementPageSuivante: false, echec: failure),
      (page) => state = state.copierAvec(
        chargementPageSuivante: false,
        analyses: [...?state.analyses, ...page.analyses],
        aPageSuivante: page.aPageSuivante,
        pageCourante: pageSuivante,
      ),
    );
  }

  Future<void> appliquerFiltres(FiltresHistorique filtres) async {
    state = state.copierAvec(filtres: filtres);
    await charger();
  }

  Future<void> reinitialiserFiltres() => appliquerFiltres(const FiltresHistorique());
}

final historiqueProvider = StateNotifierProvider.autoDispose<HistoriqueNotifier, HistoriqueState>(
  (ref) => HistoriqueNotifier(
    sl<ListerAnalysesUseCase>(),
    sl<ObtenirStatistiquesRapidesUseCase>(),
    sl<DeclencherExportUseCase>(),
  ),
);
