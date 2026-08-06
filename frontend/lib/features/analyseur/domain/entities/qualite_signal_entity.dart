import 'package:equatable/equatable.dart';

/// Indicateurs de qualité du signal reçu, toujours calculés à partir d'un
/// [SpectreBrutEntity] réel (voir domain/services/calculateur_qualite_signal.dart)
/// — jamais de valeur en dur affichée dans la carte "Aperçu en Temps Réel".
class QualiteSignalEntity extends Equatable {
  final double snrDb;
  final double intensitePourcentage;
  final double bruit;
  final double qualiteGlobalePourcentage;

  const QualiteSignalEntity({
    required this.snrDb,
    required this.intensitePourcentage,
    required this.bruit,
    required this.qualiteGlobalePourcentage,
  });

  @override
  List<Object?> get props => [snrDb, intensitePourcentage, bruit, qualiteGlobalePourcentage];
}
