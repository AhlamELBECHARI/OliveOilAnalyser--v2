import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/supervision_entity.dart';
import '../../domain/usecases/obtenir_supervision_usecase.dart';
import '../../domain/usecases/resoudre_alerte_usecase.dart';

class SupervisionState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final SupervisionEntity? supervision;

  const SupervisionState({this.enChargement = false, this.echec, this.supervision});

  SupervisionState copierAvec({
    bool? enChargement,
    Failure? echec,
    SupervisionEntity? supervision,
    bool effacerErreur = false,
  }) {
    return SupervisionState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      supervision: supervision ?? this.supervision,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, supervision];
}

class SupervisionNotifier extends StateNotifier<SupervisionState> {
  final ObtenirSupervisionUseCase _obtenirSupervision;
  final ResoudreAlerteUseCase _resoudreAlerte;

  SupervisionNotifier(this._obtenirSupervision, this._resoudreAlerte)
      : super(const SupervisionState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirSupervision(const NoParams());
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (donnees) => state = state.copierAvec(enChargement: false, supervision: donnees),
    );
  }

  /// Recharge tout l'écran après résolution : plus simple et plus sûr
  /// qu'un retrait local de la liste, puisque la résolution d'une alerte
  /// peut aussi faire évoluer d'autres compteurs affichés (anomalies...).
  Future<void> resoudreAlerte(int alerteId) async {
    final resultat = await _resoudreAlerte(alerteId);
    if (!mounted) return;
    resultat.fold((failure) => state = state.copierAvec(echec: failure), (_) => charger());
  }
}

final supervisionProvider =
    StateNotifierProvider.autoDispose<SupervisionNotifier, SupervisionState>(
  (ref) => SupervisionNotifier(sl<ObtenirSupervisionUseCase>(), sl<ResoudreAlerteUseCase>()),
);
