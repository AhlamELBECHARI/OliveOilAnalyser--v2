import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:olive_iq_app/core/navigation/coquille_navigation.dart';
import 'package:olive_iq_app/features/dashboard/presentation/widgets/barre_navigation_bas.dart';
import 'package:olive_iq_app/l10n/generated/app_localizations.dart';

/// Écran factice minimal pour chaque onglet : un compteur en état local
/// (pour vérifier qu'un onglet quitté puis retrouvé N'EST PAS recréé — la
/// pile/état de chaque branche doit survivre au changement d'onglet) et un
/// bouton qui pousse un sous-écran via context.push, exactement comme les
/// vrais écrans de l'app (voir dashboard_screen.dart, historique_screen.dart)
/// — jamais un Navigator.push imperatif qui contournerait go_router.
///
/// Les libellés ("Page ...") sont volontairement distincts des libellés de
/// la barre de navigation ("Accueil", "Historique"...) pour ne pas fausser
/// les recherches par texte de ce test.
class _EcranOnglet extends StatefulWidget {
  final String nom;
  final String cheminSousEcran;

  const _EcranOnglet({required this.nom, required this.cheminSousEcran});

  @override
  State<_EcranOnglet> createState() => _EcranOngletState();
}

class _EcranOngletState extends State<_EcranOnglet> {
  int _compteur = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page ${widget.nom}')),
      body: Column(
        children: [
          Text('Compteur ${widget.nom}: $_compteur'),
          ElevatedButton(
            onPressed: () => setState(() => _compteur++),
            child: const Text('Incrémenter'),
          ),
          ElevatedButton(
            onPressed: () => context.push(widget.cheminSousEcran),
            child: const Text('Ouvrir sous-écran'),
          ),
        ],
      ),
    );
  }
}

class _SousEcran extends StatelessWidget {
  final String nom;

  const _SousEcran({required this.nom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sous-écran de $nom')),
      body: Text('Contenu du sous-écran de $nom'),
    );
  }
}

/// Reproduit la structure réelle de core/navigation/app_router.dart (5
/// branches, même ordre, sous-écran poussé via context.push comme les
/// vrais écrans) avec des écrans factices légers plutôt que les vrais
/// écrans (qui dépendent de get_it/Riverpod) : ce test cible exclusivement
/// le mécanisme de la coquille elle-même — voir Partie A du cahier des
/// charges, le bug qu'il vérifie.
GoRouter _routeurTeste() {
  StatefulShellBranch brancheDe(String nom, String path) {
    return StatefulShellBranch(routes: [
      GoRoute(
        path: path,
        builder: (context, state) => _EcranOnglet(nom: nom, cheminSousEcran: '$path/sous-ecran'),
        routes: [
          GoRoute(path: 'sous-ecran', builder: (context, state) => _SousEcran(nom: nom)),
        ],
      ),
    ]);
  }

  return GoRouter(
    initialLocation: '/accueil',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CoquilleNavigation(navigationShell: navigationShell),
        branches: [
          brancheDe('Accueil', '/accueil'),
          brancheDe('Analyse', '/analyse'),
          brancheDe('Historique', '/historique'),
          brancheDe('Modeles', '/modeles'),
          brancheDe('Parametres', '/parametres'),
        ],
      ),
    ],
  );
}

Widget _widgetTeste(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

Finder _ongletBarre(int index) =>
    find.descendant(of: find.byType(BarreNavigationBas), matching: find.byType(InkWell)).at(index);

void main() {
  testWidgets('la barre de navigation reste visible sur les 5 onglets', (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    for (var i = 0; i < 5; i++) {
      await tester.tap(_ongletBarre(i));
      await tester.pumpAndSettle();
      expect(
        find.byType(BarreNavigationBas),
        findsOneWidget,
        reason: 'la barre du bas doit rester affichée sur chaque onglet',
      );
    }
  });

  testWidgets('la barre de navigation reste visible dans un sous-écran poussé depuis un onglet',
      (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    await tester.tap(find.text('Ouvrir sous-écran'));
    await tester.pumpAndSettle();

    expect(find.text('Sous-écran de Accueil'), findsOneWidget);
    expect(
      find.byType(BarreNavigationBas),
      findsOneWidget,
      reason: 'la barre du bas doit rester affichée même dans un sous-écran',
    );
    // Le sous-écran a bien sa propre flèche retour, sans que celle-ci ne
    // remplace ou fasse disparaître la coquille de navigation.
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('changer d\'onglet directement ne repasse jamais par Accueil et ne pousse rien par-dessus',
      (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    // Accueil -> Historique directement (onglet 2), sans navigation
    // intermédiaire par un back/pop.
    await tester.tap(_ongletBarre(2));
    await tester.pumpAndSettle();
    expect(find.text('Page Historique'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing,
        reason: "un onglet racine n'affiche jamais de flèche retour");

    // Historique -> Paramètres directement (onglet 4).
    await tester.tap(_ongletBarre(4));
    await tester.pumpAndSettle();
    expect(find.text('Page Parametres'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('chaque onglet conserve sa propre pile de navigation en le quittant puis en y revenant',
      (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    // Sur Accueil : incrémente le compteur et ouvre un sous-écran.
    await tester.tap(find.text('Incrémenter'));
    await tester.tap(find.text('Incrémenter'));
    await tester.pump();
    expect(find.text('Compteur Accueil: 2'), findsOneWidget);

    await tester.tap(find.text('Ouvrir sous-écran'));
    await tester.pumpAndSettle();
    expect(find.text('Sous-écran de Accueil'), findsOneWidget);

    // Va sur un autre onglet, puis revient sur Accueil.
    await tester.tap(_ongletBarre(3));
    await tester.pumpAndSettle();
    expect(find.text('Page Modeles'), findsOneWidget);

    await tester.tap(_ongletBarre(0));
    await tester.pumpAndSettle();

    // La pile d'Accueil est retrouvée telle quelle : toujours sur le
    // sous-écran ouvert précédemment, jamais réinitialisée à sa racine.
    expect(find.text('Sous-écran de Accueil'), findsOneWidget);
  });

  testWidgets('retaper l\'onglet déjà actif réinitialise sa pile à la racine', (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    await tester.tap(find.text('Ouvrir sous-écran'));
    await tester.pumpAndSettle();
    expect(find.text('Sous-écran de Accueil'), findsOneWidget);

    await tester.tap(_ongletBarre(0));
    await tester.pumpAndSettle();

    expect(find.text('Page Accueil'), findsOneWidget);
    expect(find.text('Sous-écran de Accueil'), findsNothing);
  });

  testWidgets(
      'le retour physique sur un onglet non-Accueil sans pile à dépiler ramène à Accueil sans faire disparaître la coquille',
      (tester) async {
    await tester.pumpWidget(_widgetTeste(_routeurTeste()));

    await tester.tap(_ongletBarre(2));
    await tester.pumpAndSettle();
    expect(find.text('Page Historique'), findsOneWidget);

    // Simule le bouton retour physique Android : rien à dépiler dans
    // l'onglet Historique, donc PopScope doit rediriger vers Accueil au
    // lieu de laisser disparaître la coquille de navigation.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Page Accueil'), findsOneWidget);
    expect(find.byType(BarreNavigationBas), findsOneWidget);
  });
}
