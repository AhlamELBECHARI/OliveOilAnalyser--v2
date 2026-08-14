import 'package:equatable/equatable.dart';

class JournalAuditEntity extends Equatable {
  final String id;
  final String action;
  final String actionLibelle;
  final String? acteurNom;
  final String? acteurEmail;
  final String cibleType;
  final String cibleId;
  final Map<String, dynamic> details;
  final DateTime dateCreation;

  const JournalAuditEntity({
    required this.id,
    required this.action,
    required this.actionLibelle,
    required this.acteurNom,
    required this.acteurEmail,
    required this.cibleType,
    required this.cibleId,
    required this.details,
    required this.dateCreation,
  });

  @override
  List<Object?> get props =>
      [id, action, actionLibelle, acteurNom, acteurEmail, cibleType, cibleId, details, dateCreation];
}
