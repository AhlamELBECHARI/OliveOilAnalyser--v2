import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/entities/spectre_historique_entity.dart';
import '../../domain/usecases/modifier_echantillon_usecase.dart';
import '../../domain/usecases/obtenir_resultat_usecase.dart';
import '../../domain/usecases/obtenir_spectre_pour_echantillon_usecase.dart';
import '../../domain/usecases/supprimer_resultat_usecase.dart';

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
  // Actions admin (suppression du résultat, correction des métadonnées de
  // l'échantillon) — voir ResultatDetailScreen.estAdmin.
  final bool actionEnCours;
  final Failure? echecAction;
  final bool resultatSupprime;
  final bool echantillonModifie;

  const ResultatDetailState({
    this.enChargement = false,
    this.echec,
    this.resultat,
    this.spectreEnChargement = false,
    this.echecSpectre,
    this.spectre,
    this.actionEnCours = false,
    this.echecAction,
    this.resultatSupprime = false,
    this.echantillonModifie = false,
  });

  ResultatDetailState copierAvec({
    bool? enChargement,
    Failure? echec,
    ResultatHistoriqueEntity? resultat,
    bool? spectreEnChargement,
    Failure? echecSpectre,
    SpectreHistoriqueEntity? spectre,
    bool? actionEnCours,
    Failure? echecAction,
    bool? resultatSupprime,
    bool? echantillonModifie,
    bool effacerErreur = false,
    bool effacerErreurSpectre = false,
    bool effacerErreurAction = false,
  }) {
    return ResultatDetailState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      resultat: resultat ?? this.resultat,
      spectreEnChargement: spectreEnChargement ?? this.spectreEnChargement,
      echecSpectre: effacerErreurSpectre ? null : (echecSpectre ?? this.echecSpectre),
      spectre: spectre ?? this.spectre,
      actionEnCours: actionEnCours ?? this.actionEnCours,
      echecAction: effacerErreurAction ? null : (echecAction ?? this.echecAction),
      resultatSupprime: resultatSupprime ?? this.resultatSupprime,
      echantillonModifie: echantillonModifie ?? this.echantillonModifie,
    );
  }

  @override
  List<Object?> get props => [
        enChargement,
        echec,
        resultat,
        spectreEnChargement,
        echecSpectre,
        spectre,
        actionEnCours,
        echecAction,
        resultatSupprime,
        echantillonModifie,
      ];
}

class ResultatDetailNotifier extends StateNotifier<ResultatDetailState> {
  final ObtenirResultatUseCase _obtenirResultatUseCase;
  final ObtenirSpectrePourEchantillonUseCase _obtenirSpectreUseCase;
  final SupprimerResultatUseCase _supprimerResultatUseCase;
  final ModifierEchantillonUseCase _modifierEchantillonUseCase;
  final String resultatId;

  ResultatDetailNotifier(
    this._obtenirResultatUseCase,
    this._obtenirSpectreUseCase,
    this._supprimerResultatUseCase,
    this._modifierEchantillonUseCase,
    this.resultatId,
  ) : super(const ResultatDetailState()) {
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

  Future<void> supprimer() async {
    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _supprimerResultatUseCase(resultatId);
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (_) => state = state.copierAvec(actionEnCours: false, resultatSupprime: true),
    );
  }

  Future<void> modifierEchantillon({
    required String producteur,
    required String variete,
    required String region,
  }) async {
    final echantillonId = state.resultat?.echantillonId;
    if (echantillonId == null) return;

    state = state.copierAvec(actionEnCours: true, effacerErreurAction: true);
    final resultat = await _modifierEchantillonUseCase(ModifierEchantillonParams(
      echantillonId: echantillonId,
      producteur: producteur,
      variete: variete,
      region: region,
    ));
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(actionEnCours: false, echecAction: failure),
      (_) {
        state = state.copierAvec(actionEnCours: false, echantillonModifie: true);
        charger();
      },
    );
  }
}

final resultatDetailProvider = StateNotifierProvider.autoDispose
    .family<ResultatDetailNotifier, ResultatDetailState, String>(
  (ref, resultatId) => ResultatDetailNotifier(
    sl<ObtenirResultatUseCase>(),
    sl<ObtenirSpectrePourEchantillonUseCase>(),
    sl<SupprimerResultatUseCase>(),
    sl<ModifierEchantillonUseCase>(),
    resultatId,
  ),
);
