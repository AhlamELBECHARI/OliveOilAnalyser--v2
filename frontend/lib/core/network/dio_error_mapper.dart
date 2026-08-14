import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Codes d'erreur stables renvoyés par le backend (voir
/// backend/core/exceptions.py::CodesErreur) — jamais le texte "detail",
/// qui n'est pas garanti traduit et ne doit jamais être affiché tel quel.
const _codeIdentifiantsInvalides = 'identifiants_invalides';
const _codeCompteVerrouille = 'compte_verrouille';
const _codeCompteDesactive = 'compte_desactive';
const _codeCodeResetInvalide = 'code_reset_invalide';
const _codeTropDeDemandes = 'trop_de_demandes';
const _codeAutoModificationInterdite = 'auto_modification_interdite';
const _codeDernierAdministrateur = 'dernier_administrateur';

/// Traduction des erreurs Dio en exceptions core/error, réutilisée par tous
/// les datasources distants. Le mapping se fait uniquement à partir du champ
/// "code" stable de la réponse : le texte "detail" ne sert qu'aux logs.
Exception traduireDioException(DioException e) {
  final statusCode = e.response?.statusCode;
  final code = extraireCodeDio(e.response?.data);

  switch (code) {
    case _codeIdentifiantsInvalides:
      return const IdentifiantsInvalidesException();
    case _codeCompteVerrouille:
      return const CompteVerrouilleException();
    case _codeCompteDesactive:
      return const CompteDesactiveException();
    case _codeCodeResetInvalide:
      return const CodeResetInvalideException();
    case _codeTropDeDemandes:
      return const TropDeDemandesException();
    case _codeAutoModificationInterdite:
      return const AutoModificationInterditeException();
    case _codeDernierAdministrateur:
      return const DernierAdministrateurException();
  }

  if (statusCode != null && statusCode >= 400 && statusCode < 500) {
    return ErreurValidationException(
      extraireDetailDio(e.response?.data) ?? 'Requête invalide.',
    );
  }

  if (statusCode != null && statusCode >= 500) {
    return const ErreurServeurException();
  }

  return const ErreurReseauException();
}

String? extraireCodeDio(dynamic data) {
  if (data is Map<String, dynamic>) {
    final code = data['code'];
    if (code is String) return code;
  }
  return null;
}

String? extraireDetailDio(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) return detail;

    for (final valeur in data.values) {
      if (valeur is List && valeur.isNotEmpty) {
        return valeur.first.toString();
      }
      if (valeur is String) return valeur;
    }
  }
  return null;
}
