import '../../domain/entities/spectre_historique_entity.dart';

class SpectreHistoriqueModel extends SpectreHistoriqueEntity {
  const SpectreHistoriqueModel({
    required super.id,
    required super.valeursX,
    required super.valeursY,
    required super.nombreSeries,
    required super.dateAcquisition,
  });

  factory SpectreHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return SpectreHistoriqueModel(
      id: json['id'] as String,
      valeursX: (json['valeurs_x'] as List).map((v) => (v as num).toDouble()).toList(),
      valeursY: (json['valeurs_y'] as List).map((v) => (v as num).toDouble()).toList(),
      nombreSeries: json['nombre_series'] as int,
      dateAcquisition: DateTime.parse(json['date_acquisition'] as String),
    );
  }
}
