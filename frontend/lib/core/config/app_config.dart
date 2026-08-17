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

  // Délais courts et explicites (cahier des charges, Partie A, section 7) :
  // une absence de réseau doit échouer vite pour laisser la place au repli
  // sur le cache local, jamais laisser un écran "en chargement" de longues
  // secondes avant de s'en apercevoir.
  static const Duration timeoutConnexion = Duration(seconds: 5);
  static const Duration timeoutReponse = Duration(seconds: 10);

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
