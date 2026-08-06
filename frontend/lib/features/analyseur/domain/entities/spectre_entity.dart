import 'package:equatable/equatable.dart';

/// Un point du spectre : absorbance mesurée à une longueur d'onde donnée
/// (nm). Unité et gamme dépendent de l'instrument réel — voir
/// data/protocole/protocole_spectrometre.dart une fois le matériel
/// documenté.
class PointSpectreEntity extends Equatable {
  final double longueurOndeNm;
  final double absorbance;

  const PointSpectreEntity({required this.longueurOndeNm, required this.absorbance});

  @override
  List<Object?> get props => [longueurOndeNm, absorbance];
}

/// Spectre complet reçu de l'analyseur à un instant donné. Le flux
/// [AnalyseurRepository.flusSpectre] peut émettre plusieurs [SpectreBrutEntity]
/// successifs pendant un SCAN (points progressivement complétés), pour un
/// rendu "temps réel" du graphique — pas uniquement le résultat final.
class SpectreBrutEntity extends Equatable {
  final List<PointSpectreEntity> points;
  final DateTime dateAcquisition;
  final bool complet;

  const SpectreBrutEntity({
    required this.points,
    required this.dateAcquisition,
    this.complet = true,
  });

  @override
  List<Object?> get props => [points, dateAcquisition, complet];
}
