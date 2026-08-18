import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/entities/appareil_decouvert_entity.dart';
import '../../domain/entities/diagnostic_bluetooth_entity.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../../domain/usecases/activer_bluetooth_usecase.dart';
import '../../domain/usecases/appairer_appareil_usecase.dart';
import '../../domain/usecases/arreter_decouverte_usecase.dart';
import '../../domain/usecases/decouvrir_appareils_proximite_usecase.dart';
import '../../domain/usecases/definir_appareil_par_defaut_usecase.dart';
import '../../domain/usecases/lister_appareils_appaires_usecase.dart';
import '../../domain/usecases/obtenir_appareil_par_defaut_usecase.dart';
import '../../domain/usecases/obtenir_diagnostic_bluetooth_usecase.dart';
import '../../domain/usecases/tester_connexion_usecase.dart';

class ConfigurationAppareilState extends Equatable {
  final bool enChargement;
  final List<AppareilAppaireEntity> appareils;
  final String? adresseParDefaut;
  final String? adresseEnTest;
  final String? adresseDernierTest;
  final bool? dernierTestReussi;

  final bool enDecouverte;
  final List<AppareilDecouvertEntity> appareilsDecouverts;
  final String? erreurDecouverte;
  final CauseEchecConnexion? causeErreurDecouverte;
  final String? adresseEnAppairage;

  final DiagnosticBluetoothEntity? diagnostic;

  const ConfigurationAppareilState({
    this.enChargement = false,
    this.appareils = const [],
    this.adresseParDefaut,
    this.adresseEnTest,
    this.adresseDernierTest,
    this.dernierTestReussi,
    this.enDecouverte = false,
    this.appareilsDecouverts = const [],
    this.erreurDecouverte,
    this.causeErreurDecouverte,
    this.adresseEnAppairage,
    this.diagnostic,
  });

  ConfigurationAppareilState copierAvec({
    bool? enChargement,
    List<AppareilAppaireEntity>? appareils,
    String? adresseParDefaut,
    String? adresseEnTest,
    String? adresseDernierTest,
    bool? dernierTestReussi,
    bool? enDecouverte,
    List<AppareilDecouvertEntity>? appareilsDecouverts,
    String? erreurDecouverte,
    CauseEchecConnexion? causeErreurDecouverte,
    String? adresseEnAppairage,
    DiagnosticBluetoothEntity? diagnostic,
    bool effacerAdresseParDefaut = false,
    bool effacerAdresseEnTest = false,
    bool effacerErreurDecouverte = false,
    bool effacerAdresseEnAppairage = false,
  }) {
    return ConfigurationAppareilState(
      enChargement: enChargement ?? this.enChargement,
      appareils: appareils ?? this.appareils,
      adresseParDefaut:
          effacerAdresseParDefaut ? null : (adresseParDefaut ?? this.adresseParDefaut),
      adresseEnTest: effacerAdresseEnTest ? null : (adresseEnTest ?? this.adresseEnTest),
      adresseDernierTest: adresseDernierTest ?? this.adresseDernierTest,
      dernierTestReussi: dernierTestReussi ?? this.dernierTestReussi,
      enDecouverte: enDecouverte ?? this.enDecouverte,
      appareilsDecouverts: appareilsDecouverts ?? this.appareilsDecouverts,
      erreurDecouverte: effacerErreurDecouverte ? null : (erreurDecouverte ?? this.erreurDecouverte),
      causeErreurDecouverte:
          effacerErreurDecouverte ? null : (causeErreurDecouverte ?? this.causeErreurDecouverte),
      adresseEnAppairage:
          effacerAdresseEnAppairage ? null : (adresseEnAppairage ?? this.adresseEnAppairage),
      diagnostic: diagnostic ?? this.diagnostic,
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
        enDecouverte,
        appareilsDecouverts,
        erreurDecouverte,
        causeErreurDecouverte,
        adresseEnAppairage,
        diagnostic,
      ];
}

/// Écran "Configuration de l'appareil" (sous-écran de l'étape Connexion) :
/// choisir l'appareil Bluetooth déjà appairé à utiliser, le mémoriser comme
/// appareil par défaut (persisté localement, voir AppareilPrefereDataSource)
/// et lancer un test de connexion ponctuel. Gère aussi désormais la
/// recherche ACTIVE des appareils à proximité (voir [lancerDecouverte]) et
/// le diagnostic Bluetooth (voir [chargerDiagnostic]).
class ConfigurationAppareilNotifier extends StateNotifier<ConfigurationAppareilState> {
  final ListerAppareilsAppairesUseCase _lister;
  final ObtenirAppareilParDefautUseCase _obtenirParDefaut;
  final DefinirAppareilParDefautUseCase _definirParDefaut;
  final TesterConnexionUseCase _testerConnexionUseCase;
  final DecouvrirAppareilsProximiteUseCase _decouvrir;
  final ArreterDecouverteUseCase _arreterDecouverte;
  final AppairerAppareilUseCase _appairer;
  final ObtenirDiagnosticBluetoothUseCase _obtenirDiagnostic;
  final ActiverBluetoothUseCase _activerBluetooth;

  StreamSubscription<AppareilDecouvertEntity>? _abonnementDecouverte;

  ConfigurationAppareilNotifier({
    required ListerAppareilsAppairesUseCase lister,
    required ObtenirAppareilParDefautUseCase obtenirParDefaut,
    required DefinirAppareilParDefautUseCase definirParDefaut,
    required TesterConnexionUseCase testerConnexionUseCase,
    required DecouvrirAppareilsProximiteUseCase decouvrir,
    required ArreterDecouverteUseCase arreterDecouverte,
    required AppairerAppareilUseCase appairer,
    required ObtenirDiagnosticBluetoothUseCase obtenirDiagnostic,
    required ActiverBluetoothUseCase activerBluetooth,
  })  : _lister = lister,
        _obtenirParDefaut = obtenirParDefaut,
        _definirParDefaut = definirParDefaut,
        _testerConnexionUseCase = testerConnexionUseCase,
        _decouvrir = decouvrir,
        _arreterDecouverte = arreterDecouverte,
        _appairer = appairer,
        _obtenirDiagnostic = obtenirDiagnostic,
        _activerBluetooth = activerBluetooth,
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

  /// Lance un balayage actif — remplace la liste précédente à chaque appel
  /// (jamais d'accumulation entre deux recherches successives). S'arrête de
  /// lui-même à la fin du balayage système, ou via [arreterDecouverteManuelle].
  Future<void> lancerDecouverte() async {
    await _abonnementDecouverte?.cancel();
    state = state.copierAvec(
      enDecouverte: true,
      appareilsDecouverts: const [],
      effacerErreurDecouverte: true,
    );

    _abonnementDecouverte = _decouvrir().listen(
      (appareil) {
        if (!mounted) return;
        final dejaVu = state.appareilsDecouverts.any((a) => a.adresse == appareil.adresse);
        if (dejaVu) return;
        state = state.copierAvec(
          appareilsDecouverts: [...state.appareilsDecouverts, appareil],
        );
      },
      onDone: () {
        if (!mounted) return;
        state = state.copierAvec(enDecouverte: false);
      },
      onError: (Object e) {
        if (!mounted) return;
        state = state.copierAvec(
          enDecouverte: false,
          erreurDecouverte: e is ErreurBluetooth ? e.message : e.toString(),
          causeErreurDecouverte: e is ErreurBluetooth ? e.cause : CauseEchecConnexion.autre,
        );
      },
    );
  }

  Future<void> arreterDecouverteManuelle() async {
    await _abonnementDecouverte?.cancel();
    _abonnementDecouverte = null;
    await _arreterDecouverte(const NoParams());
    if (!mounted) return;
    state = state.copierAvec(enDecouverte: false);
  }

  /// Appaire l'appareil découvert (sauf s'il l'est déjà) puis le mémorise
  /// directement comme appareil par défaut — la découverte sert à la
  /// configuration initiale, jamais à une sélection répétée à chaque
  /// analyse (voir AnalyseurRepository.connecterAutomatiquement).
  Future<void> appairerEtDefinir(String adresse, {required bool dejaAppaire}) async {
    if (dejaAppaire) {
      await choisirAppareilParDefaut(adresse);
      return;
    }

    state = state.copierAvec(adresseEnAppairage: adresse);
    final resultat = await _appairer(adresse);
    if (!mounted) return;
    final reussi = resultat.fold((_) => false, (ok) => ok);
    state = state.copierAvec(effacerAdresseEnAppairage: true);
    if (reussi) {
      await choisirAppareilParDefaut(adresse);
      await charger();
    }
  }

  Future<void> chargerDiagnostic() async {
    final resultat = await _obtenirDiagnostic(const NoParams());
    if (!mounted) return;
    state = state.copierAvec(diagnostic: resultat.fold((_) => null, (d) => d));
  }

  Future<void> activerBluetooth() async {
    await _activerBluetooth(const NoParams());
    await chargerDiagnostic();
  }

  @override
  void dispose() {
    // Jamais de balayage orphelin en arrière-plan une fois l'écran fermé
    // (cahier des charges, section 6 "Robustesse").
    unawaited(_abonnementDecouverte?.cancel());
    unawaited(_arreterDecouverte(const NoParams()));
    super.dispose();
  }
}

final configurationAppareilProvider = StateNotifierProvider.autoDispose<
    ConfigurationAppareilNotifier, ConfigurationAppareilState>(
  (ref) => ConfigurationAppareilNotifier(
    lister: sl<ListerAppareilsAppairesUseCase>(),
    obtenirParDefaut: sl<ObtenirAppareilParDefautUseCase>(),
    definirParDefaut: sl<DefinirAppareilParDefautUseCase>(),
    testerConnexionUseCase: sl<TesterConnexionUseCase>(),
    decouvrir: sl<DecouvrirAppareilsProximiteUseCase>(),
    arreterDecouverte: sl<ArreterDecouverteUseCase>(),
    appairer: sl<AppairerAppareilUseCase>(),
    obtenirDiagnostic: sl<ObtenirDiagnosticBluetoothUseCase>(),
    activerBluetooth: sl<ActiverBluetoothUseCase>(),
  ),
);
