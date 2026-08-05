import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/definir_locale_usecase.dart';
import '../../domain/usecases/obtenir_locale_usecase.dart';

/// Locale active de l'application. Lue depuis le stockage local au démarrage
/// (voir ParametresRepositoryImpl pour la logique de repli sur la langue du
/// système puis le français). Modifiable à chaud via [changerLocale] : la
/// MaterialApp qui observe ce provider se reconstruit immédiatement, sans
/// redémarrage.
class LocaleNotifier extends StateNotifier<Locale> {
  final ObtenirLocaleUseCase _obtenirLocaleUseCase;
  final DefinirLocaleUseCase _definirLocaleUseCase;

  LocaleNotifier(this._obtenirLocaleUseCase, this._definirLocaleUseCase) : super(const Locale('fr')) {
    _charger();
  }

  Future<void> _charger() async {
    final resultat = await _obtenirLocaleUseCase(const NoParams());
    resultat.fold((_) {}, (locale) => state = locale);
  }

  Future<void> changerLocale(Locale locale) async {
    state = locale;
    await _definirLocaleUseCase(DefinirLocaleParams(locale: locale));
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(sl<ObtenirLocaleUseCase>(), sl<DefinirLocaleUseCase>()),
);
