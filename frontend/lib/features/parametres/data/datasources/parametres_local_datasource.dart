import 'package:shared_preferences/shared_preferences.dart';

abstract class ParametresLocalDataSource {
  Future<String?> lireCodeLangue();

  Future<void> enregistrerCodeLangue(String codeLangue);

  /// 'clair', 'sombre' ou 'systeme' — voir ThemeModeExtension.
  Future<String?> lireModeTheme();

  Future<void> enregistrerModeTheme(String modeTheme);
}

class ParametresLocalDataSourceImpl implements ParametresLocalDataSource {
  static const _cleCodeLangue = 'olive_iq_code_langue';
  static const _cleModeTheme = 'olive_iq_mode_theme';

  final SharedPreferences preferences;

  const ParametresLocalDataSourceImpl({required this.preferences});

  @override
  Future<String?> lireCodeLangue() async => preferences.getString(_cleCodeLangue);

  @override
  Future<void> enregistrerCodeLangue(String codeLangue) async {
    await preferences.setString(_cleCodeLangue, codeLangue);
  }

  @override
  Future<String?> lireModeTheme() async => preferences.getString(_cleModeTheme);

  @override
  Future<void> enregistrerModeTheme(String modeTheme) async {
    await preferences.setString(_cleModeTheme, modeTheme);
  }
}
