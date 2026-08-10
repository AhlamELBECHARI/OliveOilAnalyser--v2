import '../../domain/entities/rapport_export_entity.dart';

class RapportExportModel extends RapportExportEntity {
  const RapportExportModel({required super.id, required super.format, required super.nomFichier});

  factory RapportExportModel.fromJson(Map<String, dynamic> json) {
    final cheminFichier = json['chemin_fichier'] as String?;
    return RapportExportModel(
      id: json['id'] as String,
      format: json['format'] as String,
      nomFichier:
          (cheminFichier != null && cheminFichier.isNotEmpty) ? cheminFichier.split('/').last : null,
    );
  }
}
