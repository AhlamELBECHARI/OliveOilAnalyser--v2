import '../../../../core/storage/token_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  });

  Future<bool> possedeSessionLocale();

  Future<String?> obtenirRoleSession();

  Future<void> supprimerSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorageService tokenStorage;

  const AuthLocalDataSourceImpl({required this.tokenStorage});

  @override
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await tokenStorage.enregistrerTokens(accessToken: accessToken, refreshToken: refreshToken);
    await tokenStorage.enregistrerRole(role);
  }

  @override
  Future<bool> possedeSessionLocale() => tokenStorage.possedeTokens();

  @override
  Future<String?> obtenirRoleSession() => tokenStorage.lireRole();

  @override
  Future<void> supprimerSession() => tokenStorage.supprimerTokens();
}
