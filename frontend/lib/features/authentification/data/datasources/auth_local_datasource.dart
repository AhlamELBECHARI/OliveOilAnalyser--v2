import '../../../../core/storage/token_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
  });

  Future<bool> possedeSessionLocale();

  Future<void> supprimerSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorageService tokenStorage;

  const AuthLocalDataSourceImpl({required this.tokenStorage});

  @override
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
  }) {
    return tokenStorage.enregistrerTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<bool> possedeSessionLocale() => tokenStorage.possedeTokens();

  @override
  Future<void> supprimerSession() => tokenStorage.supprimerTokens();
}
