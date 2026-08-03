/// Configuration d'environnement de l'application. Ne jamais coder une URL
/// d'API en dur ailleurs dans le code : toujours passer par [AppConfig.apiBaseUrl].
class AppConfig {
  const AppConfig._();

  /// URL de base de l'API Django REST. Surchargeable au build avec :
  /// `flutter run --dart-define=API_BASE_URL=https://mon-domaine/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration timeoutConnexion = Duration(seconds: 15);
  static const Duration timeoutReponse = Duration(seconds: 15);
}
