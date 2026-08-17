import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé des tokens JWT (et du rôle de l'utilisateur connecté).
/// Utilise le keystore/keychain natif via flutter_secure_storage — jamais
/// SharedPreferences, qui n'est pas chiffré.
class TokenStorageService {
  static const _cleAccessToken = 'olive_iq_access_token';
  static const _cleRefreshToken = 'olive_iq_refresh_token';
  // Persisté séparément des tokens (jamais décodé depuis le JWT) : sert
  // uniquement à choisir la coquille de navigation (utilisateur/admin) au
  // démarrage de l'app, avant tout appel réseau — voir main.dart.
  static const _cleRole = 'olive_iq_role';
  // Horodatage de la dernière fois où le serveur a réellement confirmé la
  // session (login ou refresh réussi) — jamais déduit du JWT. Sert
  // uniquement à borner la durée de validité d'une session hors ligne (voir
  // AuthLocalDataSourceImpl.obtenirEtatSessionLocale), jamais à décider de
  // la validité réelle du token, qui reste l'affaire exclusive du serveur.
  static const _cleDerniereAuthentification = 'olive_iq_derniere_authentification';

  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> enregistrerTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _cleAccessToken, value: accessToken),
      _storage.write(key: _cleRefreshToken, value: refreshToken),
    ]);
  }

  Future<void> enregistrerAccessToken(String accessToken) {
    return _storage.write(key: _cleAccessToken, value: accessToken);
  }

  Future<String?> lireAccessToken() => _storage.read(key: _cleAccessToken);

  Future<String?> lireRefreshToken() => _storage.read(key: _cleRefreshToken);

  Future<void> enregistrerRole(String role) => _storage.write(key: _cleRole, value: role);

  Future<String?> lireRole() => _storage.read(key: _cleRole);

  Future<void> enregistrerDerniereAuthentification(DateTime instant) =>
      _storage.write(key: _cleDerniereAuthentification, value: instant.toIso8601String());

  Future<DateTime?> lireDerniereAuthentification() async {
    final valeur = await _storage.read(key: _cleDerniereAuthentification);
    return valeur == null ? null : DateTime.tryParse(valeur);
  }

  Future<bool> possedeTokens() async {
    final refresh = await lireRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> supprimerTokens() async {
    await Future.wait([
      _storage.delete(key: _cleAccessToken),
      _storage.delete(key: _cleRefreshToken),
      _storage.delete(key: _cleRole),
      _storage.delete(key: _cleDerniereAuthentification),
    ]);
  }
}
