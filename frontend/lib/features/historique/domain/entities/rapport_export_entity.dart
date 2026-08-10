import 'package:equatable/equatable.dart';

/// Rapport créé par POST /api/analyses/export/ — le fichier est ensuite
/// récupéré via GET /api/rapports/{id}/telecharger/.
class RapportExportEntity extends Equatable {
  final String id;
  final String format;
  final String? nomFichier;

  const RapportExportEntity({required this.id, required this.format, required this.nomFichier});

  @override
  List<Object?> get props => [id, format, nomFichier];
}
