import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/commande_analyseur.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../../domain/entities/info_appareil_analyseur_entity.dart';
import '../../domain/entities/spectre_entity.dart';
import '../../domain/repositories/analyseur_repository.dart';
import '../protocole/protocole_spectrometre.dart' as protocole;

/// Implémentation Bluetooth Classic (SPP) de [AnalyseurRepository], via
/// flutter_bluetooth_serial. Toutes les hypothèses de protocole (nom de
/// l'appareil, format des trames) sont isolées dans
/// data/protocole/protocole_spectrometre.dart — ce fichier ne fait
/// qu'orchestrer connexion/lecture/écriture, jamais d'hypothèse sur le
/// contenu des trames.
///
/// Connexion automatique : au premier appel de [connecterAutomatiquement],
/// recherche l'appareil déjà appairé au nom configuré et s'y connecte seule
/// (aucune liste, aucune sélection utilisateur). En cas de coupure, une
/// reconnexion est retentée automatiquement à intervalles espacés jusqu'à
/// ce que [liberer] soit appelé.
///
/// N'a pas pu être testée avec un vrai instrument dans cette session (pas
/// de matériel disponible, développement fait sur Windows desktop où
/// flutter_bluetooth_serial n'a pas d'implémentation native) : à valider
/// manuellement sur un appareil Android avec le spectromètre appairé dès
/// que possible.
class AnalyseurBluetoothImpl implements AnalyseurRepository {
  static const _delaiEntreTentatives = Duration(seconds: 5);
  static const _delaiTimeoutInfoAppareil = Duration(seconds: 3);

  final _etatController = StreamController<EtatConnexionAnalyseurEntity>.broadcast();
  final _spectreController = StreamController<SpectreBrutEntity>.broadcast();
  final _tampon = protocole.TamponTrames();
  final _pointsAcquisitionEnCours = <PointSpectreEntity>[];

  EtatConnexionAnalyseurEntity _etatActuel = const EtatConnexionAnalyseurEntity.deconnecte();
  BluetoothConnection? _connexion;
  StreamSubscription<Uint8List>? _abonnementEntree;
  Timer? _minuteurReconnexion;
  bool _arretDemande = false;
  Completer<({String numeroSerie, String firmware, int? batterie})>? _reponseInfoEnAttente;

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

  /// Bluetooth Classic (SPP) exige, selon la version d'Android, la
  /// localisation (pré-Android 12) ou les permissions granulaires
  /// Bluetooth (Android 12+) pour lister/découvrir des appareils. On
  /// demande les deux jeux : le système ignore celles non applicables.
  Future<bool> _verifierPermissions() async {
    final statuts = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuts.values.every((statut) => statut.isGranted);
  }

  @override
  Future<void> connecterAutomatiquement() async {
    _arretDemande = false;
    _publierEtat(const EtatConnexionAnalyseurEntity.recherche());

    final permissionsAccordees = await _verifierPermissions();
    if (!permissionsAccordees) {
      _publierEtat(const EtatConnexionAnalyseurEntity.erreur(
        "Permissions Bluetooth/localisation refusées : impossible de rechercher l'analyseur. "
        'Autorisez-les dans les réglages de l\'application.',
      ));
      return;
    }

    await _tenterConnexion();
  }

  Future<void> _tenterConnexion() async {
    if (_arretDemande) return;

    try {
      final appareilsAppaires = await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? appareil;
      for (final candidat in appareilsAppaires) {
        if (candidat.name == protocole.nomAppareilAttendu) {
          appareil = candidat;
          break;
        }
      }
      if (appareil == null) {
        throw StateError(
          "Appareil « ${protocole.nomAppareilAttendu} » non appairé. "
          "Appairez-le d'abord dans les réglages Bluetooth du téléphone.",
        );
      }

      _publierEtat(const EtatConnexionAnalyseurEntity.recherche());
      final connexion = await BluetoothConnection.toAddress(appareil.address);
      if (_arretDemande) {
        await connexion.finish();
        return;
      }

      _connexion = connexion;
      _publierEtat(const EtatConnexionAnalyseurEntity.connecte());

      _abonnementEntree = connexion.input?.listen(
        _traiterOctetsRecus,
        onDone: _gererDeconnexion,
        onError: (_) => _gererDeconnexion(),
      );
    } catch (e) {
      _publierEtat(EtatConnexionAnalyseurEntity.erreur(e.toString()));
      _planifierReconnexion();
    }
  }

  void _gererDeconnexion() {
    _connexion = null;
    if (_arretDemande) {
      _publierEtat(const EtatConnexionAnalyseurEntity.deconnecte());
      return;
    }
    _publierEtat(
      const EtatConnexionAnalyseurEntity.erreur('Connexion Bluetooth perdue. Nouvelle tentative...'),
    );
    _planifierReconnexion();
  }

  void _planifierReconnexion() {
    if (_arretDemande) return;
    _minuteurReconnexion?.cancel();
    _minuteurReconnexion = Timer(_delaiEntreTentatives, _tenterConnexion);
  }

  void _traiterOctetsRecus(Uint8List octets) {
    for (final ligne in _tampon.ajouter(octets)) {
      final point = protocole.parserLignePoint(ligne);
      if (point != null) {
        _pointsAcquisitionEnCours.add(point);
        _spectreController.add(SpectreBrutEntity(
          points: List.unmodifiable(_pointsAcquisitionEnCours),
          dateAcquisition: DateTime.now(),
          complet: false,
        ));
        continue;
      }

      if (ligne == protocole.ligneFinScan) {
        _spectreController.add(SpectreBrutEntity(
          points: List.unmodifiable(_pointsAcquisitionEnCours),
          dateAcquisition: DateTime.now(),
          complet: true,
        ));
        _pointsAcquisitionEnCours.clear();
        continue;
      }

      final info = protocole.parserLigneInfo(ligne);
      if (info != null) {
        _reponseInfoEnAttente?.complete(info);
      }
    }
  }

  @override
  Future<void> envoyerCommande(CommandeAnalyseur commande) async {
    final connexion = _connexion;
    if (connexion == null || !connexion.isConnected) {
      throw StateError('Aucun analyseur connecté.');
    }
    if (commande == CommandeAnalyseur.demarrerAcquisition) {
      _pointsAcquisitionEnCours.clear();
    }
    connexion.output.add(protocole.encoderCommande(commande));
    await connexion.output.allSent;
  }

  @override
  Future<InfoAppareilAnalyseurEntity?> obtenirInfoAppareil() async {
    final connexion = _connexion;
    if (connexion == null || !connexion.isConnected) return null;

    _reponseInfoEnAttente = Completer();
    connexion.output.add(protocole.encoderCommandeInfoAppareil());
    await connexion.output.allSent;

    final info = await _reponseInfoEnAttente!.future.timeout(
      _delaiTimeoutInfoAppareil,
      onTimeout: () => (numeroSerie: 'Inconnu', firmware: 'Inconnu', batterie: null),
    );
    _reponseInfoEnAttente = null;

    return InfoAppareilAnalyseurEntity(
      nom: protocole.nomAppareilAttendu,
      type: 'Spectromètre NIR',
      numeroSerie: info.numeroSerie,
      firmware: info.firmware,
      niveauBatteriePourcentage: info.batterie,
    );
  }

  @override
  Future<void> liberer() async {
    _arretDemande = true;
    _minuteurReconnexion?.cancel();
    await _abonnementEntree?.cancel();
    await _connexion?.finish();
    await _etatController.close();
    await _spectreController.close();
  }
}
