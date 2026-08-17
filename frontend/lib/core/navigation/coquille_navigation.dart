import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/widgets/barre_navigation_bas.dart';
import '../sync/indicateur_etat_sync.dart';

/// Coquille de navigation partagée par les 5 onglets. La
/// BottomNavigationBar est déclarée UNE SEULE FOIS ici — jamais dans un
/// écran d'onglet individuel — et reste donc visible en permanence, y
/// compris dans les sous-écrans poussés à l'intérieur d'un onglet : voir
/// core/navigation/app_router.dart, où chaque branche (StatefulShellBranch)
/// possède son propre Navigator imbriqué et sa propre pile, préservée quand
/// on change d'onglet puis qu'on y revient.
class CoquilleNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CoquilleNavigation({super.key, required this.navigationShell});

  void _onTap(int index) {
    // Retaper l'onglet déjà actif ramène à sa racine (comportement standard
    // d'une barre de navigation) ; changer d'onglet restaure sa pile telle
    // que l'utilisateur l'a laissée, sans jamais la réinitialiser.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // `canPop` n'est consulté par Flutter QUE si aucun Navigator imbriqué
      // (celui de l'onglet actif) ne peut lui-même dépiler quelque chose :
      // ce PopScope ne s'active donc jamais tant qu'il reste un sous-écran
      // ouvert dans l'onglet courant — le bouton retour physique recule
      // d'abord dans SA pile, jamais dans celle d'un autre onglet.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Onglet non-Accueil et plus rien à dépiler dedans : on revient à
        // Accueil plutôt que de laisser le retour physique faire
        // disparaître la coquille de navigation (ou fermer l'app).
        navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IndicateurEtatSync(),
            BarreNavigationBas(
              indexActif: navigationShell.currentIndex,
              onTap: _onTap,
            ),
          ],
        ),
      ),
    );
  }
}
