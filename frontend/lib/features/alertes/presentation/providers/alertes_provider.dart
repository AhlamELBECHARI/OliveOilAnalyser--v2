import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/alerte_entity.dart';
import '../../domain/usecases/lister_alertes_usecase.dart';

class AlertesState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final List<AlerteEntity>? alertes;

  const AlertesState({this.enChargement = false, this.echec, this.alertes});

  AlertesState copierAvec({
    bool? enChargement,
    Failure? echec,
    List<AlerteEntity>? alertes,
    bool effacerErreur = false,
  }) {
    return AlertesState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      alertes: alertes ?? this.alertes,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, alertes];
}

class AlertesNotifier extends StateNotifier<AlertesState> {
  final ListerAlertesUseCase _listerAlertesUseCase;

  AlertesNotifier(this._listerAlertesUseCase) : super(const AlertesState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _listerAlertesUseCase(const NoParams());
    // La requête peut se résoudre après que ce notifier autoDispose ait
    // déjà été libéré (écran fermé pendant l'appel) : sans ce garde, l'appel
    // à `state =` ci-dessous lève "Bad state: ... after dispose".
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (alertes) => state = state.copierAvec(enChargement: false, alertes: alertes),
    );
  }
}

final alertesProvider = StateNotifierProvider.autoDispose<AlertesNotifier, AlertesState>(
  (ref) => AlertesNotifier(sl<ListerAlertesUseCase>()),
);
