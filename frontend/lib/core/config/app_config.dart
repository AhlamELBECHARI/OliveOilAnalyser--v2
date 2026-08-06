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

  /// Bascule entre l'implémentation Bluetooth réelle (AnalyseurBluetoothImpl)
  /// et le simulateur NIR (AnalyseurSimuleImpl), tant que le protocole du
  /// spectromètre n'est pas documenté par le fabricant. Seul point de
  /// configuration de ce choix (voir core/di/injection_container.dart) :
  /// jamais de `if` dispersé ailleurs dans le code. Surchargeable au build
  /// avec `--dart-define=UTILISER_ANALYSEUR_SIMULE=false` une fois le
  /// matériel disponible.
  static const bool utiliserAnalyseurSimule = bool.fromEnvironment(
    'UTILISER_ANALYSEUR_SIMULE',
    defaultValue: true,
  );
}
