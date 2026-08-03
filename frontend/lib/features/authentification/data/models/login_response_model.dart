import '../../domain/entities/auth_session_entity.dart';
import 'utilisateur_model.dart';

/// Reflète exactement la réponse de POST /api/auth/login/ :
/// {"access": "...", "refresh": "...", "utilisateur": {...}}
class LoginResponseModel {
  final String access;
  final String refresh;
  final UtilisateurModel utilisateur;

  const LoginResponseModel({
    required this.access,
    required this.refresh,
    required this.utilisateur,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      utilisateur:
          UtilisateurModel.fromJson(json['utilisateur'] as Map<String, dynamic>),
    );
  }

  AuthSessionEntity versEntity() {
    return AuthSessionEntity(
      accessToken: access,
      refreshToken: refresh,
      utilisateur: utilisateur,
    );
  }
}
