import 'package:flutter/material.dart';

/// Point d'accès à la navigation depuis des couches sans BuildContext
/// (ex. le callback onSessionExpiree déclenché par core/network en cas de
/// refresh token invalide, bien après que l'écran d'origine ait changé).
class AppNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void retourAuLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void versAccueil() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/accueil',
      (route) => false,
    );
  }
}
