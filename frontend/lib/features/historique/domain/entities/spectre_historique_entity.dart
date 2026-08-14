import 'package:equatable/equatable.dart';

/// Miroir de backend.spectres.models.Spectre pour l'onglet "Spectre" de
/// l'écran de détail (voir ResultatDetailScreen) — GET /api/spectres/?echantillon=.
class SpectreHistoriqueEntity extends Equatable {
  final String id;
  final List<double> valeursX;
  final List<double> valeursY;
  final int nombreSeries;
  final DateTime dateAcquisition;

  const SpectreHistoriqueEntity({
    required this.id,
    required this.valeursX,
    required this.valeursY,
    required this.nombreSeries,
    required this.dateAcquisition,
  });

  @override
  List<Object?> get props => [id, valeursX, valeursY, nombreSeries, dateAcquisition];
}
