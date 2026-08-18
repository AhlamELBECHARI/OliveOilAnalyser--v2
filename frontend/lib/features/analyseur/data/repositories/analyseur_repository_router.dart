import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/entities/appareil_decouvert_entity.dart';
import '../../domain/entities/commande_analyseur.dart';
import '../../domain/entities/diagnostic_bluetooth_entity.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../../domain/entities/info_appareil_analyseur_entity.dart';
import '../../domain/entities/resultat_scan_entity.dart';
import '../../domain/entities/spectre_entity.dart';
import '../../domain/repositories/analyseur_repository.dart';
import '../local/mode_simulateur_datasource.dart';

/// Seul point de choix entre le simulateur et le Bluetooth réel, désormais
/// modifiable À L'EXÉCUTION (voir ModeSimulateurDataSource) plutôt qu'à la
/// compilation. Délègue purement selon le mode courant, SANS repli
/// silencieux vers le simulateur en cas d'échec réel — un échec du
/// Bluetooth reste un échec visible, jamais masqué.
///
/// Les deux implémentations sont construites une seule fois (jamais
/// recréées à chaque bascule) pour ne pas perdre l'appareil par défaut
/// mémorisé côté Bluetooth réel ; seul l'appel actif change. Si le mode
/// change entre deux appels à [connecterAutomatiquement], l'implémentation
/// précédemment active est libérée avant de basculer, pour ne jamais laisser
/// une connexion ou un balayage orphelin tourner en arrière-plan.
class AnalyseurRepositoryRouter implements AnalyseurRepository {
  final AnalyseurRepository _simule;
  final AnalyseurRepository _bluetooth;
  final ModeSimulateurDataSource _modeSimulateur;

  AnalyseurRepository? _dernierActif;

  AnalyseurRepositoryRouter({
    required AnalyseurRepository simule,
    required AnalyseurRepository bluetooth,
    required ModeSimulateurDataSource modeSimulateur,
  })  : _simule = simule,
        _bluetooth = bluetooth,
        _modeSimulateur = modeSimulateur;

  AnalyseurRepository get _actif => _modeSimulateur.estActif() ? _simule : _bluetooth;

  bool get modeSimulateurActif => _modeSimulateur.estActif();

  @override
  Stream<EtatConnexionAnalyseurEntity> get flusEtatConnexion => _actif.flusEtatConnexion;

  @override
  Stream<SpectreBrutEntity> get flusSpectre => _actif.flusSpectre;

  @override
  Stream<ResultatScanEntity> get flusResultat => _actif.flusResultat;

  @override
  Future<void> connecterAutomatiquement() async {
    final actif = _actif;
    if (_dernierActif != null && !identical(_dernierActif, actif)) {
      await _dernierActif!.liberer();
    }
    _dernierActif = actif;
    return actif.connecterAutomatiquement();
  }

  @override
  Future<void> envoyerCommande(CommandeAnalyseur commande) => _actif.envoyerCommande(commande);

  @override
  Future<InfoAppareilAnalyseurEntity?> obtenirInfoAppareil() => _actif.obtenirInfoAppareil();

  @override
  Future<void> liberer() => (_dernierActif ?? _actif).liberer();

  @override
  Future<List<AppareilAppaireEntity>> listerAppareilsAppaires() =>
      _actif.listerAppareilsAppaires();

  @override
  Future<void> definirAppareilParDefaut(String? adresse) =>
      _actif.definirAppareilParDefaut(adresse);

  @override
  Future<String?> obtenirAppareilParDefaut() => _actif.obtenirAppareilParDefaut();

  @override
  Future<bool> testerConnexion(String adresse) => _actif.testerConnexion(adresse);

  @override
  Stream<AppareilDecouvertEntity> decouvrirAppareilsProximite() =>
      _actif.decouvrirAppareilsProximite();

  @override
  Future<void> arreterDecouverte() => _actif.arreterDecouverte();

  @override
  Future<DiagnosticBluetoothEntity> obtenirDiagnostic() => _actif.obtenirDiagnostic();

  @override
  Future<void> activerBluetooth() => _actif.activerBluetooth();

  @override
  Future<bool> appairerAppareil(String adresse) => _actif.appairerAppareil(adresse);
}
