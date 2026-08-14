import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'barre_navigation_admin.dart';

/// Coquille de navigation de l'espace admin — même mécanique que
/// CoquilleNavigation (pile par onglet préservée, bouton retour physique
/// qui recule dans la pile de l'onglet actif avant de revenir à
/// Supervision), mais jamais partagée avec la coquille utilisateur : un
/// administrateur ne voit pas l'application utilisateur enrichie.
class CoquilleNavigationAdmin extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CoquilleNavigationAdmin({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BarreNavigationAdmin(
          indexActif: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
