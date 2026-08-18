import 'dart:async';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/entities/appareil_decouvert_entity.dart';
import '../../domain/entities/commande_analyseur.dart';
import '../../domain/entities/diagnostic_bluetooth_entity.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../../domain/entities/info_appareil_analyseur_entity.dart';
import '../../domain/entities/resultat_scan_entity.dart';
import '../../domain/entities/spectre_entity.dart';
import '../../domain/repositories/analyseur_repository.dart';
import '../local/appareil_prefere_datasource.dart';
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
/// Chaque cause de blocage (permission refusée/refusée définitivement,
/// Bluetooth désactivé, localisation désactivée sur Android ≤ 11, appareil
/// introuvable) est diagnostiquée EXPLICITEMENT avant toute tentative — voir
/// [_verifierPreRequisConnexion] — jamais un échec silencieux : la
/// Presentation doit toujours pouvoir afficher un message et une action
/// adaptés (cahier des charges, Partie B, section 3).
class AnalyseurBluetoothImpl implements AnalyseurRepository {
  static const _delaiEntreTentatives = Duration(seconds: 5);
  static const _delaiTimeoutInfoAppareil = Duration(seconds: 3);
  static const _delaiTimeoutTest = Duration(seconds: 8);

  final AppareilPrefereDataSource appareilPrefere;

  AnalyseurBluetoothImpl({required this.appareilPrefere});

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

  StreamSubscription<BluetoothDiscoveryResult>? _abonnementDecouverte;
  int _dernierNombreAppareilsDetectes = 0;
  DateTime? _dateDernierBalayage;
  int? _sdkAndroidCache;

  @override
  Stream<EtatConnexionAnalyseurEntity> get flusEtatConnexion async* {
    yield _etatActuel;
    yield* _etatController.stream;
  }

  @override
  Stream<SpectreBrutEntity> get flusSpectre => _spectreController.stream;

  // Voir AnalyseurRepository.flusResultat : le protocole réel (encore non
  // documenté par le fabricant) ne transmet aujourd'hui aucune trame de
  // résultat, seulement le spectre brut — ce flux ne peut donc jamais rien
  // émettre pour l'instant.
  @override
  Stream<ResultatScanEntity> get flusResultat => const Stream.empty();

  void _publierEtat(EtatConnexionAnalyseurEntity etat) {
    _etatActuel = etat;
    _etatController.add(etat);
  }

  /// Version d'API Android (mise en cache, ne change jamais en cours de
  /// session) — sert uniquement à savoir si la localisation est réellement
  /// exigée par la découverte Bluetooth Classic (Android ≤ 11 seulement,
  /// voir android:usesPermissionFlags="neverForLocation" dans le manifeste).
  Future<int?> _sdkAndroid() async {
    if (_sdkAndroidCache != null) return _sdkAndroidCache;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _sdkAndroidCache = info.version.sdkInt;
    } catch (_) {
      _sdkAndroidCache = null;
    }
    return _sdkAndroidCache;
  }

  EtatPermission _versEtatPermission(PermissionStatus statut) {
    if (statut.isGranted) return EtatPermission.accordee;
    if (statut.isPermanentlyDenied) return EtatPermission.refuseeDefinitivement;
    return EtatPermission.refusee;
  }

  /// Diagnostique, DANS L'ORDRE, chaque cause possible de blocage avant
  /// toute tentative de connexion/découverte : adaptateur désactivé,
  /// permissions refusées (simplement ou définitivement), puis — seulement
  /// si réellement exigée sur cette version d'Android — service de
  /// localisation désactivé. Retourne `null` si tout est en ordre.
  Future<CauseEchecConnexion?> _verifierPreRequisConnexion() async {
    final bluetoothActif = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    if (!bluetoothActif) return CauseEchecConnexion.bluetoothDesactive;

    final statuts = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuts.values.any((s) => s.isPermanentlyDenied)) {
      return CauseEchecConnexion.permissionRefuseeDefinitivement;
    }
    if (statuts.values.any((s) => !s.isGranted)) {
      return CauseEchecConnexion.permissionRefusee;
    }

    final sdkInt = await _sdkAndroid();
    if (sdkInt != null && sdkInt <= 30) {
      final localisationActive = await Geolocator.isLocationServiceEnabled();
      if (!localisationActive) return CauseEchecConnexion.localisationDesactivee;
    }

    return null;
  }

  String _messagePourCause(CauseEchecConnexion cause) {
    switch (cause) {
      case CauseEchecConnexion.permissionRefusee:
        return "Permissions Bluetooth/localisation refusées : impossible de rechercher l'analyseur. "
            "Autorisez-les pour continuer.";
      case CauseEchecConnexion.permissionRefuseeDefinitivement:
        return 'Permissions refusées définitivement. Ouvrez les réglages de l\'application pour les '
            'autoriser manuellement.';
      case CauseEchecConnexion.bluetoothDesactive:
        return "Le Bluetooth du téléphone est désactivé.";
      case CauseEchecConnexion.localisationDesactivee:
        return 'Le service de localisation du téléphone est désactivé (requis pour la recherche '
            'Bluetooth sur cette version d\'Android).';
      case CauseEchecConnexion.appareilIntrouvable:
        return "Appareil « ${protocole.nomAppareilAttendu} » non appairé. Appairez-le d'abord dans "
            "les réglages Bluetooth du téléphone, ou choisissez-le dans « Configurer l'appareil ».";
      case CauseEchecConnexion.autre:
        return 'Connexion impossible.';
    }
  }

  @override
  Future<void> connecterAutomatiquement() async {
    _arretDemande = false;
    _publierEtat(const EtatConnexionAnalyseurEntity.recherche());

    final cause = await _verifierPreRequisConnexion();
    if (cause != null) {
      _publierEtat(EtatConnexionAnalyseurEntity.erreur(_messagePourCause(cause), cause: cause));
      return;
    }

    await _tenterConnexion();
  }

  Future<void> _tenterConnexion() async {
    if (_arretDemande) return;

    try {
      final appareilsAppaires = await FlutterBluetoothSerial.instance.getBondedDevices();
      // L'appareil mémorisé dans l'écran de configuration prime sur la
      // détection par nom — nécessaire dès que plusieurs analyseurs
      // partagent le même nom de modèle, ou si le fabricant permet de le
      // renommer à l'appairage.
      final adressePreferee = await appareilPrefere.obtenirAdresseParDefaut();
      BluetoothDevice? appareil;
      if (adressePreferee != null) {
        for (final candidat in appareilsAppaires) {
          if (candidat.address == adressePreferee) {
            appareil = candidat;
            break;
          }
        }
      }
      if (appareil == null) {
        for (final candidat in appareilsAppaires) {
          if (candidat.name == protocole.nomAppareilAttendu) {
            appareil = candidat;
            break;
          }
        }
      }
      if (appareil == null) {
        throw StateError(_messagePourCause(CauseEchecConnexion.appareilIntrouvable));
      }

      _publierEtat(const EtatConnexionAnalyseurEntity.recherche());
      // Délai explicite (cahier des charges, section 6) : sans lui, un
      // appareil appairé mais hors de portée/éteint peut laisser ce Future
      // en attente indéfiniment côté OS.
      final connexion = await BluetoothConnection.toAddress(appareil.address).timeout(
        _delaiTimeoutTest,
        onTimeout: () => throw TimeoutException('Délai de connexion dépassé.'),
      );
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
    } on StateError catch (e) {
      _publierEtat(EtatConnexionAnalyseurEntity.erreur(
        e.message,
        cause: CauseEchecConnexion.appareilIntrouvable,
      ));
      _planifierReconnexion();
    } catch (e) {
      _publierEtat(
        EtatConnexionAnalyseurEntity.erreur(e.toString(), cause: CauseEchecConnexion.autre),
      );
      _planifierReconnexion();
    }
  }

  void _gererDeconnexion() {
    _connexion = null;
    if (_arretDemande) {
      _publierEtat(const EtatConnexionAnalyseurEntity.deconnecte());
      return;
    }
    _publierEtat(EtatConnexionAnalyseurEntity.erreur(
      'Connexion Bluetooth perdue. Nouvelle tentative...',
      cause: CauseEchecConnexion.autre,
    ));
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
    await _abonnementDecouverte?.cancel();
    _abonnementDecouverte = null;
    await _connexion?.finish();
    await _etatController.close();
    await _spectreController.close();
  }

  @override
  Future<List<AppareilAppaireEntity>> listerAppareilsAppaires() async {
    final statut = await Permission.bluetoothConnect.request();
    if (!statut.isGranted) return const [];
    final appareils = await FlutterBluetoothSerial.instance.getBondedDevices();
    return appareils
        .map((a) => AppareilAppaireEntity(adresse: a.address, nom: a.name ?? a.address))
        .toList();
  }

  @override
  Future<void> definirAppareilParDefaut(String? adresse) {
    return appareilPrefere.definirAdresseParDefaut(adresse);
  }

  @override
  Future<String?> obtenirAppareilParDefaut() {
    return appareilPrefere.obtenirAdresseParDefaut();
  }

  @override
  Future<bool> testerConnexion(String adresse) async {
    BluetoothConnection? connexionTest;
    try {
      connexionTest = await BluetoothConnection.toAddress(adresse).timeout(_delaiTimeoutTest);
      return connexionTest.isConnected;
    } catch (_) {
      return false;
    } finally {
      await connexionTest?.finish();
    }
  }

  /// Découverte ACTIVE (pas seulement les appareils appairés) — voir
  /// AnalyseurRepository.decouvrirAppareilsProximite. Le Stream se ferme de
  /// lui-même à la fin du balayage système ; annuler l'abonnement (ou
  /// appeler [arreterDecouverte]) l'arrête avant son terme.
  @override
  Stream<AppareilDecouvertEntity> decouvrirAppareilsProximite() {
    late StreamController<AppareilDecouvertEntity> controller;
    final adressesVues = <String>{};

    Future<void> arreter() async {
      await _abonnementDecouverte?.cancel();
      _abonnementDecouverte = null;
      await FlutterBluetoothSerial.instance.cancelDiscovery();
    }

    Future<void> demarrer() async {
      final cause = await _verifierPreRequisConnexion();
      // "appareilIntrouvable" n'a pas de sens pour une découverte (elle ne
      // dépend d'aucun appareil déjà appairé) : seuls l'adaptateur et les
      // permissions la bloquent réellement.
      final blocageReel = cause == CauseEchecConnexion.bluetoothDesactive ||
          cause == CauseEchecConnexion.permissionRefusee ||
          cause == CauseEchecConnexion.permissionRefuseeDefinitivement ||
          cause == CauseEchecConnexion.localisationDesactivee;
      if (blocageReel) {
        controller.addError(ErreurBluetooth(_messagePourCause(cause!), cause));
        await controller.close();
        return;
      }

      _dernierNombreAppareilsDetectes = 0;
      _dateDernierBalayage = DateTime.now();

      await _abonnementDecouverte?.cancel();
      _abonnementDecouverte = FlutterBluetoothSerial.instance.startDiscovery().listen(
        (resultat) {
          if (!adressesVues.add(resultat.device.address)) return; // déjà vu ce balayage
          _dernierNombreAppareilsDetectes++;
          if (!controller.isClosed) {
            controller.add(AppareilDecouvertEntity(
              adresse: resultat.device.address,
              nom: resultat.device.name ?? resultat.device.address,
              forceSignal: resultat.rssi == 0 ? null : resultat.rssi,
              dejaAppaire: resultat.device.bondState.isBonded,
            ));
          }
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
        },
        onError: (Object e) {
          if (!controller.isClosed) controller.addError(e);
        },
      );
    }

    controller = StreamController<AppareilDecouvertEntity>(onCancel: arreter);
    demarrer();
    return controller.stream;
  }

  @override
  Future<void> arreterDecouverte() async {
    await _abonnementDecouverte?.cancel();
    _abonnementDecouverte = null;
    await FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  @override
  Future<DiagnosticBluetoothEntity> obtenirDiagnostic() async {
    final bluetoothActif = await FlutterBluetoothSerial.instance.isEnabled;
    final sdkInt = await _sdkAndroid();
    final localisationRequise = sdkInt != null && sdkInt <= 30;

    final statutScan = await Permission.bluetoothScan.status;
    final statutConnect = await Permission.bluetoothConnect.status;
    final statutLocalisation = await Permission.locationWhenInUse.status;
    bool serviceLocalisationActif;
    try {
      serviceLocalisationActif = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      serviceLocalisationActif = true;
    }

    return DiagnosticBluetoothEntity(
      etatAdaptateur: bluetoothActif == null
          ? EtatAdaptateurBluetooth.inconnu
          : (bluetoothActif ? EtatAdaptateurBluetooth.actif : EtatAdaptateurBluetooth.inactif),
      permissions: [
        PermissionDiagnostiquee(
          type: PermissionBluetooth.bluetoothScan,
          etat: _versEtatPermission(statutScan),
        ),
        PermissionDiagnostiquee(
          type: PermissionBluetooth.bluetoothConnect,
          etat: _versEtatPermission(statutConnect),
        ),
        PermissionDiagnostiquee(
          type: PermissionBluetooth.localisation,
          etat: _versEtatPermission(statutLocalisation),
        ),
      ],
      serviceLocalisationActif: serviceLocalisationActif,
      localisationRequise: localisationRequise,
      nombreAppareilsClassicDetectes: _dernierNombreAppareilsDetectes,
      dateDernierBalayage: _dateDernierBalayage,
    );
  }

  @override
  Future<void> activerBluetooth() async {
    await FlutterBluetoothSerial.instance.requestEnable();
  }

  @override
  Future<bool> appairerAppareil(String adresse) async {
    try {
      return await FlutterBluetoothSerial.instance.bondDeviceAtAddress(adresse) ?? false;
    } catch (_) {
      return false;
    }
  }
}
