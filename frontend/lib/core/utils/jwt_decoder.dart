import 'dart:convert';

/// Décodage MINIMAL du payload d'un JWT (aucune vérification de signature :
/// le token vient du secure storage local, déjà émis par notre propre
/// backend — ce décodage sert uniquement à en lire des champs publics comme
/// `jti`, jamais à valider son authenticité). Évite d'ajouter une
/// dépendance tierce pour un besoin aussi restreint.
Map<String, dynamic>? decoderPayloadJwt(String token) {
  final segments = token.split('.');
  if (segments.length != 3) return null;

  try {
    var payload = segments[1];
    payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
    final decode = base64Url.decode(payload);
    return jsonDecode(utf8.decode(decode)) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

/// Renvoie le `jti` (identifiant unique) du refresh token, ou `null` si le
/// token est illisible.
String? jtiDuToken(String token) {
  final payload = decoderPayloadJwt(token);
  final jti = payload?['jti'];
  return jti is String ? jti : null;
}
