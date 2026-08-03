import 'package:equatable/equatable.dart';

import 'utilisateur_entity.dart';

class AuthSessionEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UtilisateurEntity utilisateur;

  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.utilisateur,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, utilisateur];
}
