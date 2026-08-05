import 'dart:ui';

abstract class ParametresRepository {
  /// Locale active : valeur mémorisée localement si elle existe, sinon la
  /// langue du système si elle est supportée, sinon le français par défaut.
  Future<Locale> obtenirLocale();

  Future<void> definirLocale(Locale locale);
}
