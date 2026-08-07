import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/definir_mode_theme_usecase.dart';
import '../../domain/usecases/obtenir_mode_theme_usecase.dart';

/// Thème actif de l'application (clair/sombre/système), persisté localement
/// exactement comme la langue (voir LocaleNotifier) et appliqué
/// immédiatement : la MaterialApp qui observe ce provider se reconstruit
/// dès [changerModeTheme], sans redémarrage.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ObtenirModeThemeUseCase _obtenirModeThemeUseCase;
  final DefinirModeThemeUseCase _definirModeThemeUseCase;

  ThemeModeNotifier(this._obtenirModeThemeUseCase, this._definirModeThemeUseCase)
      : super(ThemeMode.system) {
    _charger();
  }

  Future<void> _charger() async {
    final resultat = await _obtenirModeThemeUseCase(const NoParams());
    if (!mounted) return;
    resultat.fold((_) {}, (mode) => state = mode);
  }

  Future<void> changerModeTheme(ThemeMode mode) async {
    state = mode;
    await _definirModeThemeUseCase(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(sl<ObtenirModeThemeUseCase>(), sl<DefinirModeThemeUseCase>()),
);
