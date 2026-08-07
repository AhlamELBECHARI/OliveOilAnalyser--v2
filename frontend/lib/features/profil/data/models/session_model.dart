import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.dateCreation,
    required super.dateExpiration,
    required super.estCourante,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateExpiration: DateTime.parse(json['date_expiration'] as String),
      estCourante: json['est_courante'] as bool,
    );
  }
}
