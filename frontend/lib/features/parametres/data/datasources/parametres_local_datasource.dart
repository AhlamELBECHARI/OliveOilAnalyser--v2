import 'package:shared_preferences/shared_preferences.dart';

abstract class ParametresLocalDataSource {
  Future<String?> lireCodeLangue();

  Future<void> enregistrerCodeLangue(String codeLangue);
}

class ParametresLocalDataSourceImpl implements ParametresLocalDataSource {
  static const _cleCodeLangue = 'olive_iq_code_langue';

  final SharedPreferences preferences;

  const ParametresLocalDataSourceImpl({required this.preferences});

  @override
  Future<String?> lireCodeLangue() async => preferences.getString(_cleCodeLangue);

  @override
  Future<void> enregistrerCodeLangue(String codeLangue) async {
    await preferences.setString(_cleCodeLangue, codeLangue);
  }
}
