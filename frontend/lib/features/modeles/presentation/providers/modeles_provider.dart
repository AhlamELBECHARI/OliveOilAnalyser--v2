import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/modele_entity.dart';
import '../../domain/usecases/lister_modeles_usecase.dart';

class ModelesState extends Equatable {
  final bool enChargement;
  final Failure? echec;
  final List<ModeleEntity>? modeles;

  const ModelesState({this.enChargement = false, this.echec, this.modeles});

  ModelesState copierAvec({
    bool? enChargement,
    Failure? echec,
    List<ModeleEntity>? modeles,
    bool effacerErreur = false,
  }) {
    return ModelesState(
      enChargement: enChargement ?? this.enChargement,
      echec: effacerErreur ? null : (echec ?? this.echec),
      modeles: modeles ?? this.modeles,
    );
  }

  @override
  List<Object?> get props => [enChargement, echec, modeles];
}

class ModelesNotifier extends StateNotifier<ModelesState> {
  final ListerModelesUseCase _listerModelesUseCase;

  ModelesNotifier(this._listerModelesUseCase) : super(const ModelesState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _listerModelesUseCase(const NoParams());
    // Voir AlertesNotifier.charger : évite "Bad state: ... after dispose"
    // si l'écran a été fermé (provider autoDispose libéré) pendant l'appel.
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (modeles) => state = state.copierAvec(enChargement: false, modeles: modeles),
    );
  }
}

final modelesProvider = StateNotifierProvider.autoDispose<ModelesNotifier, ModelesState>(
  (ref) => ModelesNotifier(sl<ListerModelesUseCase>()),
);
