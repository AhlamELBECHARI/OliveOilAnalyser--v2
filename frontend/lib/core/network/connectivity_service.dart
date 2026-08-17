import 'package:connectivity_plus/connectivity_plus.dart';

/// Source unique de vérité pour l'état de connectivité de l'appareil.
/// Utilisée par l'écran de connexion (message hors ligne), l'indicateur
/// global en ligne/hors ligne (Partie C) et SynchronisationService
/// (déclenchement au retour réseau) — jamais une instance de [Connectivity]
/// recréée ailleurs. "En ligne" signifie ici qu'une interface réseau est
/// active (WiFi/données mobiles), pas que le serveur est joignable : seule
/// une requête qui aboutit (ou échoue) fait foi de ça.
class ConnectivityService {
  final Connectivity _connectivite;

  ConnectivityService({Connectivity? connectivite}) : _connectivite = connectivite ?? Connectivity();

  Future<bool> estEnLigne() async {
    final resultats = await _connectivite.checkConnectivity();
    return _uneInterfaceActive(resultats);
  }

  Stream<bool> get flusEnLigne =>
      _connectivite.onConnectivityChanged.map(_uneInterfaceActive);

  bool _uneInterfaceActive(List<ConnectivityResult> resultats) =>
      resultats.any((resultat) => resultat != ConnectivityResult.none);
}
