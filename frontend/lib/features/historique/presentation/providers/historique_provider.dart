import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/demande_export_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';
import '../../domain/usecases/declencher_export_usecase.dart';
import '../../domain/usecases/lister_analyses_usecase.dart';
import '../../domain/usecases/obtenir_statistiques_rapides_usecase.dart';
import '../../domain/usecases/telecharger_rapport_usecase.dart';

/// Résultat d'un export réussi, prêt à être écrit sur disque par la
/// Presentation (voir core/files/telechargeur_fichier.dart) — l'écriture de
/// fichier local est une action de plateforme, pas une préoccupation du
/// provider.
typedef FichierExporte = ({String nomFichier, List<int> octets});

class HistoriqueState extends Equatable {
  final bool enChargement;
  final bool chargementPageSuivante;
  final Failure? echec;
  final List<AnalyseHistoriqueEntity>? analyses;
  final bool aPageSuivante;
  final int pageCourante;
  final int totalAnalyses;
  final FiltresHistorique filtres;
  final StatistiquesRapidesEntity? statistiques;
  final bool exportEnCours;
  final bool modeSelection;
  final Set<String> idsSelectionnes;
  final ContenuExport? contenuExportEnCours;
  final String? formatExportEnCours;

  const HistoriqueState({
    this.enChargement = false,
    this.chargementPageSuivante = false,
    this.echec,
    this.analyses,
    this.aPageSuivante = false,
    this.pageCourante = 1,
    this.totalAnalyses = 0,
    this.filtres = const FiltresHistorique(),
    this.statistiques,
    this.exportEnCours = false,
    this.modeSelection = false,
    this.idsSelectionnes = const {},
    this.contenuExportEnCours,
    this.formatExportEnCours,
  });

  HistoriqueState copierAvec({
    bool? enChargement,
    bool? chargementPageSuivante,
    Failure? echec,
    List<AnalyseHistoriqueEntity>? analyses,
    bool? aPageSuivante,
    int? pageCourante,
    int? totalAnalyses,
    FiltresHistorique? filtres,
    StatistiquesRapidesEntity? statistiques,
    bool? exportEnCours,
    bool? modeSelection,
    Set<String>? idsSelectionnes,
    ContenuExport? contenuExportEnCours,
    String? formatExportEnCours,
    bool effacerErreur = false,
    bool reinitialiserExportEnCours = false,
  }) {
    return HistoriqueState(
      enChargement: enChargement ?? this.enChargement,
      chargementPageSuivante: chargementPageSuivante ?? this.chargementPageSuivante,
      echec: effacerErreur ? null : (echec ?? this.echec),
      analyses: analyses ?? this.analyses,
      aPageSuivante: aPageSuivante ?? this.aPageSuivante,
      pageCourante: pageCourante ?? this.pageCourante,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      filtres: filtres ?? this.filtres,
      statistiques: statistiques ?? this.statistiques,
      exportEnCours: exportEnCours ?? this.exportEnCours,
      modeSelection: modeSelection ?? this.modeSelection,
      idsSelectionnes: idsSelectionnes ?? this.idsSelectionnes,
      contenuExportEnCours:
          reinitialiserExportEnCours ? null : (contenuExportEnCours ?? this.contenuExportEnCours),
      formatExportEnCours:
          reinitialiserExportEnCours ? null : (formatExportEnCours ?? this.formatExportEnCours),
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
        totalAnalyses,
        filtres,
        statistiques,
        exportEnCours,
        modeSelection,
        idsSelectionnes,
        contenuExportEnCours,
        formatExportEnCours,
      ];
}

class HistoriqueNotifier extends StateNotifier<HistoriqueState> {
  final ListerAnalysesUseCase _listerAnalyses;
  final ObtenirStatistiquesRapidesUseCase _obtenirStatistiquesRapides;
  final DeclencherExportUseCase _declencherExport;
  final TelechargerRapportUseCase _telechargerRapport;

  HistoriqueNotifier(
    this._listerAnalyses,
    this._obtenirStatistiquesRapides,
    this._declencherExport,
    this._telechargerRapport,
  ) : super(const HistoriqueState()) {
    charger();
  }

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
        totalAnalyses: page.total,
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
        totalAnalyses: page.total,
        pageCourante: pageSuivante,
      ),
    );
  }

  Future<void> appliquerFiltres(FiltresHistorique filtres) async {
    state = state.copierAvec(filtres: filtres);
    await charger();
  }

  Future<void> reinitialiserFiltres() => appliquerFiltres(const FiltresHistorique());

  // --- Mode sélection manuelle (export) ---

  void activerModeSelection({required ContenuExport contenu, required String format}) {
    state = state.copierAvec(
      modeSelection: true,
      idsSelectionnes: const {},
      contenuExportEnCours: contenu,
      formatExportEnCours: format,
    );
  }

  void desactiverModeSelection() {
    state = state.copierAvec(
      modeSelection: false,
      idsSelectionnes: const {},
      reinitialiserExportEnCours: true,
    );
  }

  void basculerSelection(String id) {
    final ensemble = {...state.idsSelectionnes};
    if (!ensemble.remove(id)) ensemble.add(id);
    state = state.copierAvec(idsSelectionnes: ensemble);
  }

  /// Sélectionne toutes les analyses actuellement chargées en mémoire — pas
  /// nécessairement toutes celles qui correspondent aux filtres si d'autres
  /// pages n'ont pas encore été chargées ("Charger plus d'analyses").
  void toutSelectionner() {
    state = state.copierAvec(idsSelectionnes: (state.analyses ?? []).map((a) => a.id).toSet());
  }

  // --- Export ---

  /// Déclenche la génération du fichier puis le télécharge, en une seule
  /// opération suivie par l'écran (voir HistoriqueScreen) : le provider ne
  /// touche jamais au système de fichiers, il renvoie juste les octets.
  Future<Either<Failure, FichierExporte>> declencherEtTelecharger(
    DemandeExportEntity demande,
  ) async {
    state = state.copierAvec(exportEnCours: true, effacerErreur: true);
    final resultatExport = await _declencherExport(demande);
    if (!mounted) return const Left(ErreurReseauFailure());

    return resultatExport.fold(
      (failure) async {
        state = state.copierAvec(exportEnCours: false, echec: failure);
        return Left(failure);
      },
      (rapport) async {
        final resultatBytes = await _telechargerRapport(rapport.id);
        if (!mounted) return const Left(ErreurReseauFailure());
        return resultatBytes.fold(
          (failure) {
            state = state.copierAvec(exportEnCours: false, echec: failure);
            return Left(failure);
          },
          (octets) {
            state = state.copierAvec(
              exportEnCours: false,
              modeSelection: false,
              idsSelectionnes: const {},
              reinitialiserExportEnCours: true,
            );
            final nomFichier = rapport.nomFichier ?? 'export.${rapport.format.toLowerCase()}';
            return Right((nomFichier: nomFichier, octets: octets));
          },
        );
      },
    );
  }

  Future<Either<Failure, FichierExporte>> exporterSelection() {
    return declencherEtTelecharger(DemandeExportEntity(
      contenu: state.contenuExportEnCours!,
      format: state.formatExportEnCours!,
      identifiants: state.idsSelectionnes.toList(),
    ));
  }
}

final historiqueProvider = StateNotifierProvider.autoDispose<HistoriqueNotifier, HistoriqueState>(
  (ref) => HistoriqueNotifier(
    sl<ListerAnalysesUseCase>(),
    sl<ObtenirStatistiquesRapidesUseCase>(),
    sl<DeclencherExportUseCase>(),
    sl<TelechargerRapportUseCase>(),
  ),
);
