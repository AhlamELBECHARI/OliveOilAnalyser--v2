import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Point d'accès à la navigation depuis des couches sans BuildContext (ex.
/// le callback onSessionExpiree déclenché par core/network en cas de
/// refresh token invalide, bien après que l'écran d'origine ait changé).
/// Le router go_router est construit une seule fois, au démarrage de l'app
/// (voir initialiserRouter, appelé depuis main() une fois la session locale
/// vérifiée), puis réutilisé pour toute navigation programmatique.
class AppNavigator {
  late final GoRouter router;

  void initialiserRouter(String emplacementInitial) {
    router = creerRouter(emplacementInitial: emplacementInitial);
  }

  /// Quitte entièrement la coquille de navigation (déconnexion, session
  /// expirée) : `/login` est une route racine, hors du shell.
  void retourAuLogin() => router.go('/login');

  void versAccueil() => router.go('/accueil');
}
