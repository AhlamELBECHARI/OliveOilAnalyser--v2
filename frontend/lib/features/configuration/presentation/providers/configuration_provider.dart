import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/configuration_entity.dart';
import '../../domain/usecases/modifier_configuration_usecase.dart';
import '../../domain/usecases/obtenir_configuration_usecase.dart';

class ConfigurationState extends Equatable {
  final bool enChargement;
  final bool enregistrementEnCours;
  final Failure? echec;
  final ConfigurationEntity? configuration;

  const ConfigurationState({
    this.enChargement = false,
    this.enregistrementEnCours = false,
    this.echec,
    this.configuration,
  });

  ConfigurationState copierAvec({
    bool? enChargement,
    bool? enregistrementEnCours,
    Failure? echec,
    ConfigurationEntity? configuration,
    bool effacerErreur = false,
  }) {
    return ConfigurationState(
      enChargement: enChargement ?? this.enChargement,
      enregistrementEnCours: enregistrementEnCours ?? this.enregistrementEnCours,
      echec: effacerErreur ? null : (echec ?? this.echec),
      configuration: configuration ?? this.configuration,
    );
  }

  @override
  List<Object?> get props => [enChargement, enregistrementEnCours, echec, configuration];
}

class ConfigurationNotifier extends StateNotifier<ConfigurationState> {
  final ObtenirConfigurationUseCase _obtenirUseCase;
  final ModifierConfigurationUseCase _modifierUseCase;

  ConfigurationNotifier(this._obtenirUseCase, this._modifierUseCase)
      : super(const ConfigurationState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirUseCase(const NoParams());
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (configuration) => state = state.copierAvec(enChargement: false, configuration: configuration),
    );
  }

  Future<bool> modifier(ConfigurationEntity configuration) async {
    state = state.copierAvec(enregistrementEnCours: true, effacerErreur: true);
    final resultat = await _modifierUseCase(configuration);
    if (!mounted) return false;
    return resultat.fold(
      (failure) {
        state = state.copierAvec(enregistrementEnCours: false, echec: failure);
        return false;
      },
      (nouvelleConfiguration) {
        state = state.copierAvec(
          enregistrementEnCours: false,
          configuration: nouvelleConfiguration,
        );
        return true;
      },
    );
  }
}

final configurationProvider =
    StateNotifierProvider.autoDispose<ConfigurationNotifier, ConfigurationState>(
  (ref) => ConfigurationNotifier(sl<ObtenirConfigurationUseCase>(), sl<ModifierConfigurationUseCase>()),
);
