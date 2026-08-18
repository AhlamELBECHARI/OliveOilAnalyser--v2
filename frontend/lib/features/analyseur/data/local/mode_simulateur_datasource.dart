import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';

/// Persiste le choix "Mode simulateur" (Paramètres), modifiable À
/// L'EXÉCUTION — contrairement à AppConfig.utiliserAnalyseurSimule (constante
/// de compilation, conservée uniquement comme valeur par défaut tant que
/// rien n'a encore été choisi explicitement, pour ne rien casser sur les
/// builds existants). Voir AnalyseurRepositoryRouter, seul lecteur de cette
/// valeur pour décider quelle implémentation utiliser.
abstract class ModeSimulateurDataSource {
  bool estActif();
  Future<void> definir(bool actif);
}

class ModeSimulateurDataSourceImpl implements ModeSimulateurDataSource {
  static const _cle = 'analyseur_mode_simulateur_actif';

  final SharedPreferences preferences;

  const ModeSimulateurDataSourceImpl({required this.preferences});

  @override
  bool estActif() => preferences.getBool(_cle) ?? AppConfig.utiliserAnalyseurSimule;

  @override
  Future<void> definir(bool actif) => preferences.setBool(_cle, actif);
}
