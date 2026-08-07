import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;

abstract class ParametresRepository {
  /// Locale active : valeur mémorisée localement si elle existe, sinon la
  /// langue du système si elle est supportée, sinon le français par défaut.
  Future<Locale> obtenirLocale();

  Future<void> definirLocale(Locale locale);

  /// Thème actif : ThemeMode.system par défaut (aucune préférence
  /// mémorisée), sinon la valeur mémorisée localement.
  Future<ThemeMode> obtenirModeTheme();

  Future<void> definirModeTheme(ThemeMode mode);
}
