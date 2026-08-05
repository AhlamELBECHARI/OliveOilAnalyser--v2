import 'dart:ui';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/repositories/parametres_repository.dart';
import '../datasources/parametres_local_datasource.dart';

class ParametresRepositoryImpl implements ParametresRepository {
  final ParametresLocalDataSource localDataSource;
  final Locale localeSysteme;

  ParametresRepositoryImpl({
    required this.localDataSource,
    Locale? localeSysteme,
  }) : localeSysteme = localeSysteme ?? PlatformDispatcher.instance.locale;

  @override
  Future<Locale> obtenirLocale() async {
    final codeStocke = await localDataSource.lireCodeLangue();
    if (codeStocke != null) {
      final localeStockee = Locale(codeStocke);
      if (AppLocalizations.supportedLocales.contains(localeStockee)) {
        return localeStockee;
      }
    }

    // Premier lancement (ou valeur stockée non supportée) : langue du
    // système si elle est supportée, sinon français par défaut.
    final estLangueSystemeSupportee = AppLocalizations.supportedLocales
        .any((locale) => locale.languageCode == localeSysteme.languageCode);
    return estLangueSystemeSupportee ? Locale(localeSysteme.languageCode) : const Locale('fr');
  }

  @override
  Future<void> definirLocale(Locale locale) {
    return localDataSource.enregistrerCodeLangue(locale.languageCode);
  }
}
