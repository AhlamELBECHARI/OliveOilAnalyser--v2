import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/entities/spectre_historique_entity.dart';
import '../../domain/usecases/obtenir_resultat_usecase.dart';
import '../../domain/usecases/obtenir_spectre_pour_echantillon_usecase.dart';

class ResultatDetailState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final ResultatHistoriqueEntity? resultat;
  // Le spectre est chargé séparément (GET /api/spectres/?echantillon=),
  // une fois le résultat connu — voir ResultatDetailNotifier.charger.
  // `null` sans échec signifie "pas encore synchronisé", pas une erreur.
  final bool spectreEnChargement;
  final Failure? echecSpectre;
  final SpectreHistoriqueEntity? spectre;

  const ResultatDetailState({
    this.enChargement = false,
    this.echec,
    this.resultat,
    this.spectreEnChargement = false,
    this.echecSpectre,
    this.spectre,
  });

  ResultatDetailState copierAvec({
    bool? enChargement,
    Failure? echec,
    ResultatHistoriqueEntity? resultat,
    bool? spectreEnChargement,
    Failure? echecSpectre,
    SpectreHistoriqueEntity? spectre,
    bool effacerErreur = false,
    bool effacerErreurSpectre = false,
  }) {
    return ResultatDetailState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      resultat: resultat ?? this.resultat,
      spectreEnChargement: spectreEnChargement ?? this.spectreEnChargement,
      echecSpectre: effacerErreurSpectre ? null : (echecSpectre ?? this.echecSpectre),
      spectre: spectre ?? this.spectre,
    );
  }

  @override
  List<Object?> get props =>
      [enChargement, echec, resultat, spectreEnChargement, echecSpectre, spectre];
}

class ResultatDetailNotifier extends StateNotifier<ResultatDetailState> {
  final ObtenirResultatUseCase _obtenirResultatUseCase;
  final ObtenirSpectrePourEchantillonUseCase _obtenirSpectreUseCase;
  final String resultatId;

  ResultatDetailNotifier(this._obtenirResultatUseCase, this._obtenirSpectreUseCase, this.resultatId)
      : super(const ResultatDetailState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirResultatUseCase(resultatId);
    // Voir AlertesNotifier.charger : évite "Bad state: ... after dispose"
    // si l'écran a été fermé (provider autoDispose libéré) pendant l'appel.
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (donnees) {
        state = state.copierAvec(enChargement: false, resultat: donnees);
        chargerSpectre(donnees.echantillonId);
      },
    );
  }

  Future<void> chargerSpectre(String echantillonId) async {
    state = state.copierAvec(spectreEnChargement: true, effacerErreurSpectre: true);
    final resultat = await _obtenirSpectreUseCase(echantillonId);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(spectreEnChargement: false, echecSpectre: failure),
      (spectre) => state = state.copierAvec(spectreEnChargement: false, spectre: spectre),
    );
  }
}

final resultatDetailProvider = StateNotifierProvider.autoDispose
    .family<ResultatDetailNotifier, ResultatDetailState, String>(
  (ref, resultatId) => ResultatDetailNotifier(
    sl<ObtenirResultatUseCase>(),
    sl<ObtenirSpectrePourEchantillonUseCase>(),
    resultatId,
  ),
);
