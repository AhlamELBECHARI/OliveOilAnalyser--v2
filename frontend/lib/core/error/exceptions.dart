/// Exceptions techniques levées par les datasources (couche Data). Les
/// repositories les traduisent en [Failure] avant qu'elles n'atteignent le
/// domain ou la presentation.
class IdentifiantsInvalidesException implements Exception {
  const IdentifiantsInvalidesException();
}

class CompteVerrouilleException implements Exception {
  const CompteVerrouilleException();
}

class CompteDesactiveException implements Exception {
  const CompteDesactiveException();
}

class CodeResetInvalideException implements Exception {
  const CodeResetInvalideException();
}

class TropDeDemandesException implements Exception {
  const TropDeDemandesException();
}

class ErreurReseauException implements Exception {
  const ErreurReseauException();
}

class ErreurServeurException implements Exception {
  final String? message;
  const ErreurServeurException([this.message]);
}

class ErreurValidationException implements Exception {
  final String message;
  const ErreurValidationException(this.message);
}

class AutoModificationInterditeException implements Exception {
  const AutoModificationInterditeException();
}

class DernierAdministrateurException implements Exception {
  const DernierAdministrateurException();
}
