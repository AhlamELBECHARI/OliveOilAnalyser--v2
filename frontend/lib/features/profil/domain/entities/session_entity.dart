import 'package:equatable/equatable.dart';

/// Une session active = un refresh token émis (OutstandingToken côté
/// backend) ni blacklisté ni expiré. `estCourante` reflète le jti fourni
/// par ce client lui-même à la lecture (voir ProfilRepository.listerSessions),
/// jamais deviné côté serveur.
class SessionEntity extends Equatable {
  final int id;
  final DateTime dateCreation;
  final DateTime dateExpiration;
  final bool estCourante;

  const SessionEntity({
    required this.id,
    required this.dateCreation,
    required this.dateExpiration,
    required this.estCourante,
  });

  @override
  List<Object?> get props => [id, dateCreation, dateExpiration, estCourante];
}
