import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/usecases/definir_appareil_par_defaut_usecase.dart';
import '../../domain/usecases/lister_appareils_appaires_usecase.dart';
import '../../domain/usecases/obtenir_appareil_par_defaut_usecase.dart';
import '../../domain/usecases/tester_connexion_usecase.dart';

class ConfigurationAppareilState extends Equatable {
  final bool enChargement;
  final List<AppareilAppaireEntity> appareils;
  final String? adresseParDefaut;
  final String? adresseEnTest;
  final String? adresseDernierTest;
  final bool? dernierTestReussi;

  const ConfigurationAppareilState({
    this.enChargement = false,
    this.appareils = const [],
    this.adresseParDefaut,
    this.adresseEnTest,
    this.adresseDernierTest,
    this.dernierTestReussi,
  });

  ConfigurationAppareilState copierAvec({
    bool? enChargement,
    List<AppareilAppaireEntity>? appareils,
    String? adresseParDefaut,
    String? adresseEnTest,
    String? adresseDernierTest,
    bool? dernierTestReussi,
    bool effacerAdresseParDefaut = false,
    bool effacerAdresseEnTest = false,
  }) {
    return ConfigurationAppareilState(
      enChargement: enChargement ?? this.enChargement,
      appareils: appareils ?? this.appareils,
      adresseParDefaut:
          effacerAdresseParDefaut ? null : (adresseParDefaut ?? this.adresseParDefaut),
      adresseEnTest: effacerAdresseEnTest ? null : (adresseEnTest ?? this.adresseEnTest),
      adresseDernierTest: adresseDernierTest ?? this.adresseDernierTest,
      dernierTestReussi: dernierTestReussi ?? this.dernierTestReussi,
    );
  }

  @override
  List<Object?> get props => [
        enChargement,
        appareils,
        adresseParDefaut,
        adresseEnTest,
        adresseDernierTest,
        dernierTestReussi,
      ];
}

/// Écran "Configuration de l'appareil" (sous-écran de l'étape Connexion) :
/// choisir l'appareil Bluetooth déjà appairé à utiliser, le mémoriser comme
/// appareil par défaut (persisté localement, voir AppareilPrefereDataSource)
/// et lancer un test de connexion ponctuel — jamais de scan/découverte,
/// seulement les appareils déjà appairés dans les réglages du téléphone.
class ConfigurationAppareilNotifier extends StateNotifier<ConfigurationAppareilState> {
  final ListerAppareilsAppairesUseCase _lister;
  final ObtenirAppareilParDefautUseCase _obtenirParDefaut;
  final DefinirAppareilParDefautUseCase _definirParDefaut;
  final TesterConnexionUseCase _testerConnexionUseCase;

  ConfigurationAppareilNotifier({
    required ListerAppareilsAppairesUseCase lister,
    required ObtenirAppareilParDefautUseCase obtenirParDefaut,
    required DefinirAppareilParDefautUseCase definirParDefaut,
    required TesterConnexionUseCase testerConnexionUseCase,
  })  : _lister = lister,
        _obtenirParDefaut = obtenirParDefaut,
        _definirParDefaut = definirParDefaut,
        _testerConnexionUseCase = testerConnexionUseCase,
        super(const ConfigurationAppareilState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true);
    final resultatAppareils = await _lister(const NoParams());
    final resultatDefaut = await _obtenirParDefaut(const NoParams());
    if (!mounted) return;
    state = state.copierAvec(
      enChargement: false,
      appareils: resultatAppareils.fold((_) => const [], (a) => a),
      adresseParDefaut: resultatDefaut.fold((_) => null, (a) => a),
      effacerAdresseParDefaut: resultatDefaut.fold((_) => true, (a) => a == null),
    );
  }

  Future<void> choisirAppareilParDefaut(String adresse) async {
    await _definirParDefaut(adresse);
    if (!mounted) return;
    state = state.copierAvec(adresseParDefaut: adresse);
  }

  Future<void> oublierAppareilParDefaut() async {
    await _definirParDefaut(null);
    if (!mounted) return;
    state = state.copierAvec(effacerAdresseParDefaut: true);
  }

  Future<void> testerConnexion(String adresse) async {
    state = state.copierAvec(adresseEnTest: adresse);
    final resultat = await _testerConnexionUseCase(adresse);
    if (!mounted) return;
    state = state.copierAvec(
      effacerAdresseEnTest: true,
      adresseDernierTest: adresse,
      dernierTestReussi: resultat.fold((_) => false, (ok) => ok),
    );
  }
}

final configurationAppareilProvider = StateNotifierProvider.autoDispose<
    ConfigurationAppareilNotifier, ConfigurationAppareilState>(
  (ref) => ConfigurationAppareilNotifier(
    lister: sl<ListerAppareilsAppairesUseCase>(),
    obtenirParDefaut: sl<ObtenirAppareilParDefautUseCase>(),
    definirParDefaut: sl<DefinirAppareilParDefautUseCase>(),
    testerConnexionUseCase: sl<TesterConnexionUseCase>(),
  ),
);
