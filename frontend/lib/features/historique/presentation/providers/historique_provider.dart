import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/usecases/lister_historique_usecase.dart';

class HistoriqueState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final List<ResultatHistoriqueEntity>? resultats;

  const HistoriqueState({this.enChargement = false, this.echec, this.resultats});

  HistoriqueState copierAvec({
    bool? enChargement,
    Failure? echec,
    List<ResultatHistoriqueEntity>? resultats,
    bool effacerErreur = false,
  }) {
    return HistoriqueState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      resultats: resultats ?? this.resultats,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, resultats];
}

class HistoriqueNotifier extends StateNotifier<HistoriqueState> {
  final ListerHistoriqueUseCase _listerHistoriqueUseCase;

  HistoriqueNotifier(this._listerHistoriqueUseCase) : super(const HistoriqueState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _listerHistoriqueUseCase(const NoParams());
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (resultats) => state = state.copierAvec(enChargement: false, resultats: resultats),
    );
  }
}

final historiqueProvider = StateNotifierProvider.autoDispose<HistoriqueNotifier, HistoriqueState>(
  (ref) => HistoriqueNotifier(sl<ListerHistoriqueUseCase>()),
);
