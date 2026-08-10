import 'package:shared_preferences/shared_preferences.dart';

/// Persiste l'adresse Bluetooth de l'appareil choisi comme appareil par
/// défaut (écran "Configuration de l'appareil"), pour que la connexion
/// automatique cible ce même appareil aux lancements suivants.
abstract class AppareilPrefereDataSource {
  Future<String?> obtenirAdresseParDefaut();
  Future<void> definirAdresseParDefaut(String? adresse);
}

class AppareilPrefereDataSourceImpl implements AppareilPrefereDataSource {
  static const _cle = 'analyseur_adresse_appareil_par_defaut';

  final SharedPreferences preferences;

  const AppareilPrefereDataSourceImpl({required this.preferences});

  @override
  Future<String?> obtenirAdresseParDefaut() async => preferences.getString(_cle);

  @override
  Future<void> definirAdresseParDefaut(String? adresse) async {
    if (adresse == null) {
      await preferences.remove(_cle);
    } else {
      await preferences.setString(_cle, adresse);
    }
  }
}
