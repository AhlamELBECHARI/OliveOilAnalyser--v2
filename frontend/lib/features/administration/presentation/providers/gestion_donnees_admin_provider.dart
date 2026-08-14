import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/gestion_donnees_entity.dart';
import '../../domain/usecases/executer_purge_usecase.dart';
import '../../domain/usecases/obtenir_statistiques_occupation_usecase.dart';
import '../../domain/usecases/previsualiser_purge_usecase.dart';

class GestionDonneesAdminState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final StatistiquesOccupationEntity? statistiques;
  final bool apercuEnCours;
  final PurgeApercuEntity? apercu;
  final DateTime? dateLimiteApercu;
  final bool purgeEnCours;
  final bool purgeReussie;
  final Failure? echecPurge;

  const GestionDonneesAdminState({
    this.enChargement = false,
    this.echec,
    this.statistiques,
    this.apercuEnCours = false,
    this.apercu,
    this.dateLimiteApercu,
    this.purgeEnCours = false,
    this.purgeReussie = false,
    this.echecPurge,
  });

  GestionDonneesAdminState copierAvec({
    bool? enChargement,
    Failure? echec,
    StatistiquesOccupationEntity? statistiques,
    bool? apercuEnCours,
    PurgeApercuEntity? apercu,
    DateTime? dateLimiteApercu,
    bool? purgeEnCours,
    bool? purgeReussie,
    Failure? echecPurge,
    bool effacerErreur = false,
    bool effacerApercu = false,
    bool effacerErreurPurge = false,
  }) {
    return GestionDonneesAdminState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      statistiques: statistiques ?? this.statistiques,
      apercuEnCours: apercuEnCours ?? this.apercuEnCours,
      apercu: effacerApercu ? null : (apercu ?? this.apercu),
      dateLimiteApercu: effacerApercu ? null : (dateLimiteApercu ?? this.dateLimiteApercu),
      purgeEnCours: purgeEnCours ?? this.purgeEnCours,
      purgeReussie: purgeReussie ?? this.purgeReussie,
      echecPurge: effacerErreurPurge ? null : (echecPurge ?? this.echecPurge),
    );
  }

  @override
  List<Object?> get props => [
        enChargement,
        echec,
        statistiques,
        apercuEnCours,
        apercu,
        dateLimiteApercu,
        purgeEnCours,
        purgeReussie,
        echecPurge,
      ];
}

class GestionDonneesAdminNotifier extends StateNotifier<GestionDonneesAdminState> {
  final ObtenirStatistiquesOccupationUseCase _obtenirStatistiques;
  final PrevisualiserPurgeUseCase _previsualiserPurge;
  final ExecuterPurgeUseCase _executerPurge;

  GestionDonneesAdminNotifier(this._obtenirStatistiques, this._previsualiserPurge, this._executerPurge)
      : super(const GestionDonneesAdminState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirStatistiques(const NoParams());
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (statistiques) => state = state.copierAvec(enChargement: false, statistiques: statistiques),
    );
  }

  Future<void> previsualiserPurge(DateTime dateLimite) async {
    state = state.copierAvec(apercuEnCours: true, effacerApercu: true);
    final resultat = await _previsualiserPurge(dateLimite);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(apercuEnCours: false, echec: failure),
      (apercu) => state = state.copierAvec(
        apercuEnCours: false,
        apercu: apercu,
        dateLimiteApercu: dateLimite,
      ),
    );
  }

  Future<void> confirmerPurge() async {
    final dateLimite = state.dateLimiteApercu;
    if (dateLimite == null) return;
    state = state.copierAvec(purgeEnCours: true, effacerErreurPurge: true);
    final resultat = await _executerPurge(dateLimite);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(purgeEnCours: false, echecPurge: failure),
      (_) {
        state = state.copierAvec(purgeEnCours: false, purgeReussie: true, effacerApercu: true);
        charger();
      },
    );
  }
}

final gestionDonneesAdminProvider = StateNotifierProvider.autoDispose<
    GestionDonneesAdminNotifier, GestionDonneesAdminState>(
  (ref) => GestionDonneesAdminNotifier(
    sl<ObtenirStatistiquesOccupationUseCase>(),
    sl<PrevisualiserPurgeUseCase>(),
    sl<ExecuterPurgeUseCase>(),
  ),
);
