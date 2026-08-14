import '../../domain/entities/journal_audit_entity.dart';

class JournalAuditModel extends JournalAuditEntity {
  const JournalAuditModel({
    required super.id,
    required super.action,
    required super.actionLibelle,
    required super.acteurNom,
    required super.acteurEmail,
    required super.cibleType,
    required super.cibleId,
    required super.details,
    required super.dateCreation,
  });

  factory JournalAuditModel.fromJson(Map<String, dynamic> json) {
    return JournalAuditModel(
      id: json['id'] as String,
      action: json['action'] as String,
      actionLibelle: json['action_libelle'] as String,
      acteurNom: json['acteur_nom'] as String?,
      acteurEmail: json['acteur_email'] as String?,
      cibleType: json['cible_type'] as String? ?? '',
      cibleId: json['cible_id'] as String? ?? '',
      details: (json['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }
}
