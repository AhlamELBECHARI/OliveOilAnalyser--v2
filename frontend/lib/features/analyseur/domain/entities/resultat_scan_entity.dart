import 'package:equatable/equatable.dart';

/// Une prédiction "brute" pour une grandeur donnée, produite par le pipeline
/// de scoring à l'issue d'un scan. `grandeurPredite`/`typeModele` reprennent
/// exactement le vocabulaire de backend.modeles.models
/// (GrandeurPredite/TypeModele) — jamais réinterprétés côté mobile.
/// Volontairement indépendante des modèles réels enregistrés côté backend :
/// voir features/nouvelle_analyse, qui la répartit ensuite sur les modèles
/// actifs correspondants pour construire le payload POST /api/resultats/.
class PredictionBruteEntity extends Equatable {
  final String grandeurPredite; // 'acidite' | 'indice_peroxyde' | 'authenticite'
  final String typeModele; // 'regression' | 'classification'
  final double? valeurNumerique;
  final String? classePredite; // 'pure' | 'melangee'
  final double? scoreConfiance;

  const PredictionBruteEntity({
    required this.grandeurPredite,
    required this.typeModele,
    this.valeurNumerique,
    this.classePredite,
    this.scoreConfiance,
  });

  @override
  List<Object?> get props =>
      [grandeurPredite, typeModele, valeurNumerique, classePredite, scoreConfiance];
}

/// Résultat calculé à l'issue d'un scan complet.
class ResultatScanEntity extends Equatable {
  final List<PredictionBruteEntity> predictions;
  final int dureeAnalyseSecondes;

  const ResultatScanEntity({required this.predictions, required this.dureeAnalyseSecondes});

  @override
  List<Object?> get props => [predictions, dureeAnalyseSecondes];
}
