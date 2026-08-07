import 'package:go_router/go_router.dart';

import '../../features/alertes/presentation/screens/alertes_screen.dart';
import '../../features/authentification/presentation/screens/login_screen.dart';
import '../../features/authentification/presentation/screens/reset_password/email_reset_screen.dart';
import '../../features/dashboard/domain/entities/statistiques_dashboard_entity.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/repartition_qualite_screen.dart';
import '../../features/historique/presentation/screens/historique_screen.dart';
import '../../features/historique/presentation/screens/resultat_detail_screen.dart';
import '../../features/configuration/presentation/screens/preferences_analyse_screen.dart';
import '../../features/modeles/presentation/screens/modeles_screen.dart';
import '../../features/nouvelle_analyse/presentation/screens/nouvelle_analyse_screen.dart';
import '../../features/profil/presentation/screens/a_propos_screen.dart';
import '../../features/profil/presentation/screens/centre_aide_screen.dart';
import '../../features/profil/presentation/screens/gestion_donnees_screen.dart';
import '../../features/profil/presentation/screens/informations_personnelles_screen.dart';
import '../../features/profil/presentation/screens/mentions_legales_screen.dart';
import '../../features/profil/presentation/screens/profil_screen.dart';
import '../../features/profil/presentation/screens/securite_screen.dart';
import '../../features/profil/presentation/screens/sessions_actives_screen.dart';
import 'coquille_navigation.dart';

/// Construit l'arbre de routes de l'app avec go_router.
///
/// Une StatefulShellRoute.indexedStack porte les 5 onglets : chaque branche
/// a son propre Navigator imbriqué (donc sa propre pile, préservée d'un
/// changement d'onglet à l'autre) et la BottomNavigationBar, déclarée une
/// seule fois dans CoquilleNavigation, reste affichée sur tous les
/// sous-écrans. Voir la Partie A du cahier des charges : avant ce
/// refactor, les onglets étaient ouverts par Navigator.push, empilés
/// par-dessus la coquille (barre du bas disparue, flèche retour intruse).
///
/// Seules exceptions, hors coquille (pas de barre du bas) : le login et le
/// parcours mot de passe oublié.
GoRouter creerRouter({required String emplacementInitial}) {
  return GoRouter(
    initialLocation: emplacementInitial,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/mot-de-passe-oublie',
        builder: (context, state) => const EmailResetScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CoquilleNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/accueil',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(path: 'alertes', builder: (context, state) => const AlertesScreen()),
                GoRoute(
                  path: 'repartition-qualite',
                  builder: (context, state) => RepartitionQualiteScreen(
                    repartition: state.extra! as List<RepartitionQualiteEntity>,
                  ),
                ),
                GoRoute(
                  path: 'resultat/:id',
                  builder: (context, state) =>
                      ResultatDetailScreen(resultatId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/analyse', builder: (context, state) => const NouvelleAnalyseScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/historique',
              builder: (context, state) => const HistoriqueScreen(),
              routes: [
                GoRoute(
                  path: 'resultat/:id',
                  builder: (context, state) =>
                      ResultatDetailScreen(resultatId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/modeles', builder: (context, state) => const ModelesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/parametres',
              builder: (context, state) => const ProfilScreen(),
              routes: [
                GoRoute(
                  path: 'informations-personnelles',
                  builder: (context, state) => const InformationsPersonnellesScreen(),
                ),
                GoRoute(path: 'securite', builder: (context, state) => const SecuriteScreen()),
                GoRoute(
                  path: 'sessions',
                  builder: (context, state) => const SessionsActivesScreen(),
                ),
                GoRoute(
                  path: 'preferences-analyse',
                  builder: (context, state) => const PreferencesAnalyseScreen(),
                ),
                GoRoute(
                  path: 'gestion-donnees',
                  builder: (context, state) => const GestionDonneesScreen(),
                ),
                GoRoute(path: 'a-propos', builder: (context, state) => const AProposScreen()),
                GoRoute(path: 'aide', builder: (context, state) => const CentreAideScreen()),
                GoRoute(
                  path: 'mentions-legales',
                  builder: (context, state) => const MentionsLegalesScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
