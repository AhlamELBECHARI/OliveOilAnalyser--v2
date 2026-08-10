import 'dart:async';
import 'dart:math' as math;

import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/entities/commande_analyseur.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../../domain/entities/info_appareil_analyseur_entity.dart';
import '../../domain/entities/spectre_entity.dart';
import '../../domain/repositories/analyseur_repository.dart';

/// Seul "appareil" que le simulateur peut proposer dans l'écran de
/// configuration — il n'y a évidemment rien à appairer en simulation, mais
/// l'écran doit rester utilisable en mode démo sans matériel.
const _appareilSimule = AppareilAppaireEntity(adresse: 'SIM-0001', nom: 'NIR-Simulateur-01');

/// Délais (ms) de chaque étape simulée — regroupés ici pour être ajustables
/// sans fouiller la logique. Le vrai timing dépendra de l'instrument réel.
class _DelaisSimulation {
  static const detection = Duration(milliseconds: 900);
  static const connexion = Duration(milliseconds: 600);
  static const background = Duration(milliseconds: 1400);
  static const calibration = Duration(milliseconds: 1400);
  static const intervalleEtapeScan = Duration(milliseconds: 220);
}

class _BandeAbsorption {
  final double centreNm;
  final double largeurNm;
  final double amplitude;

  const _BandeAbsorption({required this.centreNm, required this.largeurNm, required this.amplitude});
}

/// Bandes d'absorption caractéristiques des matières grasses (huiles) en
/// proche infrarouge — centre/largeur/amplitude approximatifs issus de la
/// littérature NIR sur les lipides (C-H, O-H). Ne prétend pas reproduire un
/// spectre calibré : sert à obtenir une allure visuellement réaliste pour
/// développer/démontrer l'UI avant que le vrai instrument ne soit
/// disponible ou documenté (voir data/protocole/protocole_spectrometre.dart
/// pour la réserve équivalente côté implémentation Bluetooth réelle).
const _bandesMatieresGrasses = [
  _BandeAbsorption(centreNm: 930, largeurNm: 40, amplitude: 0.10),
  _BandeAbsorption(centreNm: 1150, largeurNm: 35, amplitude: 0.12),
  _BandeAbsorption(centreNm: 1210, largeurNm: 30, amplitude: 0.18),
  _BandeAbsorption(centreNm: 1400, largeurNm: 50, amplitude: 0.22),
  _BandeAbsorption(centreNm: 1720, largeurNm: 25, amplitude: 0.55),
  _BandeAbsorption(centreNm: 1760, largeurNm: 25, amplitude: 0.50),
  _BandeAbsorption(centreNm: 2310, largeurNm: 30, amplitude: 0.35),
  _BandeAbsorption(centreNm: 2350, largeurNm: 30, amplitude: 0.30),
];

const _nombrePointsSpectre = 1024;
const _longueurOndeMinNm = 400.0;
const _longueurOndeMaxNm = 2500.0;
const _nombreEtapesScanProgressif = 10;

/// Implémentation simulée de [AnalyseurRepository] : génère un spectre NIR
/// plausible et rejoue la séquence complète (détection → connexion →
/// BACKGROUND → CALIBRATION → SCAN) avec des délais réalistes, sans aucun
/// matériel. Remplaçable par [AnalyseurBluetoothImpl] via get_it seul (voir
/// core/di/injection_container.dart) — l'UI ne doit constater aucune
/// différence de comportement, seulement des données différentes.
class AnalyseurSimuleImpl implements AnalyseurRepository {
  final _random = math.Random();
  final _etatController = StreamController<EtatConnexionAnalyseurEntity>.broadcast();
  final _spectreController = StreamController<SpectreBrutEntity>.broadcast();

  EtatConnexionAnalyseurEntity _etatActuel = const EtatConnexionAnalyseurEntity.deconnecte();
  int _niveauBatterie = 88;
  bool _annulationDemandee = false;
  int _generationAcquisition = 0;
  String? _adresseParDefaut;

  @override
  Stream<EtatConnexionAnalyseurEntity> get flusEtatConnexion async* {
    yield _etatActuel;
    yield* _etatController.stream;
  }

  @override
  Stream<SpectreBrutEntity> get flusSpectre => _spectreController.stream;

  void _publierEtat(EtatConnexionAnalyseurEntity etat) {
    _etatActuel = etat;
    _etatController.add(etat);
  }

  @override
  Future<void> connecterAutomatiquement() async {
    _publierEtat(const EtatConnexionAnalyseurEntity.recherche());
    await Future.delayed(_DelaisSimulation.detection);
    await Future.delayed(_DelaisSimulation.connexion);
    _publierEtat(const EtatConnexionAnalyseurEntity.connecte());
  }

  @override
  Future<InfoAppareilAnalyseurEntity?> obtenirInfoAppareil() async {
    if (_etatActuel.etat != EtatConnexion.connecte) return null;
    // Légère dérive de la batterie simulée pour que la carte "Connexion &
    // Instrument" ne montre jamais une valeur figée entre deux appels.
    _niveauBatterie = math.max(20, _niveauBatterie - _random.nextInt(2));
    return InfoAppareilAnalyseurEntity(
      nom: 'NIR-Simulateur-01',
      type: 'Spectromètre NIR (simulé)',
      numeroSerie: 'SIM-2026-00001',
      firmware: 'SIM-1.0.0',
      niveauBatteriePourcentage: _niveauBatterie,
    );
  }

  @override
  Future<void> envoyerCommande(CommandeAnalyseur commande) async {
    if (commande == CommandeAnalyseur.annulerAcquisition) {
      _annulationDemandee = true;
      return;
    }

    if (_etatActuel.etat != EtatConnexion.connecte) {
      throw StateError("Aucun analyseur connecté : impossible de démarrer l'acquisition.");
    }

    _annulationDemandee = false;
    final generation = ++_generationAcquisition;

    await Future.delayed(_DelaisSimulation.background); // BACKGROUND
    if (_annulationDemandee || generation != _generationAcquisition) return;

    await Future.delayed(_DelaisSimulation.calibration); // CALIBRATION
    if (_annulationDemandee || generation != _generationAcquisition) return;

    await _executerScanProgressif(generation); // SCAN
  }

  Future<void> _executerScanProgressif(int generation) async {
    final pointsComplets = _genererSpectreNirRealiste();
    final maintenant = DateTime.now();

    for (var etape = 1; etape <= _nombreEtapesScanProgressif; etape++) {
      if (_annulationDemandee || generation != _generationAcquisition) return;
      await Future.delayed(_DelaisSimulation.intervalleEtapeScan);
      if (_annulationDemandee || generation != _generationAcquisition) return;

      final nombrePoints = (pointsComplets.length * etape / _nombreEtapesScanProgressif).round();
      final estComplet = etape == _nombreEtapesScanProgressif;
      _spectreController.add(SpectreBrutEntity(
        points: pointsComplets.sublist(0, nombrePoints),
        dateAcquisition: maintenant,
        complet: estComplet,
      ));
    }
  }

  List<PointSpectreEntity> _genererSpectreNirRealiste() {
    final pas = (_longueurOndeMaxNm - _longueurOndeMinNm) / (_nombrePointsSpectre - 1);
    final points = <PointSpectreEntity>[];

    for (var i = 0; i < _nombrePointsSpectre; i++) {
      final longueurOnde = _longueurOndeMinNm + i * pas;
      // Ligne de base croissante avec la longueur d'onde, typique d'un
      // spectre NIR brut avant correction.
      var absorbance = 0.05 +
          (longueurOnde - _longueurOndeMinNm) / (_longueurOndeMaxNm - _longueurOndeMinNm) * 0.15;

      for (final bande in _bandesMatieresGrasses) {
        final ecartReduit = (longueurOnde - bande.centreNm) / bande.largeurNm;
        absorbance += bande.amplitude * math.exp(-ecartReduit * ecartReduit);
      }

      absorbance += (_random.nextDouble() - 0.5) * 0.02; // bruit capteur
      points.add(PointSpectreEntity(
        longueurOndeNm: double.parse(longueurOnde.toStringAsFixed(1)),
        absorbance: double.parse(absorbance.toStringAsFixed(4)),
      ));
    }
    return points;
  }

  @override
  Future<void> liberer() async {
    await _etatController.close();
    await _spectreController.close();
  }

  @override
  Future<List<AppareilAppaireEntity>> listerAppareilsAppaires() async => const [_appareilSimule];

  @override
  Future<void> definirAppareilParDefaut(String? adresse) async {
    _adresseParDefaut = adresse;
  }

  @override
  Future<String?> obtenirAppareilParDefaut() async => _adresseParDefaut;

  @override
  Future<bool> testerConnexion(String adresse) async {
    await Future.delayed(_DelaisSimulation.connexion);
    return adresse == _appareilSimule.adresse;
  }
}
