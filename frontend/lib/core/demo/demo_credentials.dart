/// Identifiants fixes utilisés par le bouton "Mode démo" de l'écran de
/// connexion. Doivent correspondre à DEMO_EMAIL/DEMO_PASSWORD dans
/// backend/dashboard/management/commands/seed_demo.py — ce compte est créé
/// automatiquement par `python manage.py seed_demo`.
///
/// Le mode démo n'est qu'un raccourci pour éviter de saisir ces identifiants
/// à la main : il déclenche une vraie connexion (POST /api/auth/login/,
/// vrais tokens JWT stockés normalement), jamais un contournement de
/// l'authentification ni des données factices côté Flutter.
class DemoCredentials {
  const DemoCredentials._();

  static const String email = 'demo@oliveiq.local';
  static const String password = 'OliveIQDemo123!';
}
