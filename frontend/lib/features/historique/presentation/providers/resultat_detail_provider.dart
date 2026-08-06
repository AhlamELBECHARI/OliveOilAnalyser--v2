import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/usecases/obtenir_resultat_usecase.dart';

class ResultatDetailState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final ResultatHistoriqueEntity? resultat;

  const ResultatDetailState({this.enChargement = false, this.echec, this.resultat});

  ResultatDetailState copierAvec({
    bool? enChargement,
    Failure? echec,
    ResultatHistoriqueEntity? resultat,
    bool effacerErreur = false,
  }) {
    return ResultatDetailState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      resultat: resultat ?? this.resultat,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, resultat];
}

class ResultatDetailNotifier extends StateNotifier<ResultatDetailState> {
  final ObtenirResultatUseCase _obtenirResultatUseCase;
  final String resultatId;

  ResultatDetailNotifier(this._obtenirResultatUseCase, this.resultatId)
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
      (donnees) => state = state.copierAvec(enChargement: false, resultat: donnees),
    );
  }
}

final resultatDetailProvider = StateNotifierProvider.autoDispose
    .family<ResultatDetailNotifier, ResultatDetailState, String>(
  (ref, resultatId) => ResultatDetailNotifier(sl<ObtenirResultatUseCase>(), resultatId),
);
