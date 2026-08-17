import 'package:equatable/equatable.dart';

import '../../../../core/domain/classification_qualite.dart';

/// Une prédiction déjà résolue sur un modèle réel (voir
/// domain/services/repartiteur_predictions.dart), prête à être écrite
/// localement puis synchronisée vers POST /api/resultats/.
class PredictionAEnregistrer extends Equatable {
  final int modeleId;
  final double? valeurNumerique;
  final String? classePredite;
  final double? scoreConfiance;

  const PredictionAEnregistrer({
    required this.modeleId,
    this.valeurNumerique,
    this.classePredite,
    this.scoreConfiance,
  });

  @override
  List<Object?> get props => [modeleId, valeurNumerique, classePredite, scoreConfiance];
}

/// Résultat prêt à être enregistré : les prédictions "brutes" du scan (voir
/// analyseur.ResultatScanEntity) ont déjà été réparties sur les modèles
/// actifs réellement enregistrés côté backend.
class ResultatACreerEntity extends Equatable {
  /// `null` si aucun modèle de régression actif pour l'acidité n'existe
  /// côté backend : dans ce cas, aucun Resultat ne peut être créé (le champ
  /// `modele_utilise` est obligatoire côté API) — voir
  /// NouvelleAnalyseNotifier, qui garde alors seulement échantillon+spectre,
  /// comme avant ce jalon.
  final double? acidite;
  final int? modeleUtiliseId;
  final double indicePeroxyde;
  final bool conforme;
  final int dureeAnalyseSecondes;
  final List<PredictionAEnregistrer> predictions;

  /// Catégorie EVOO/VOO/Lampante déjà résolue via classifierAcidite (voir
  /// domain/services/repartiteur_predictions.dart) — `null` si l'acidité ou
  /// la Configuration (seuils) n'était pas disponible au moment du calcul.
  /// Calculée une seule fois ici pour alimenter aussi bien l'affichage
  /// immédiat (étape Résultats) que le cache local des statistiques (voir
  /// core/local_storage/statistiques_locales_service.dart), jamais
  /// recalculée séparément.
  final CategorieQualiteHuile? categorie;

  const ResultatACreerEntity({
    required this.acidite,
    required this.modeleUtiliseId,
    required this.indicePeroxyde,
    required this.conforme,
    required this.dureeAnalyseSecondes,
    required this.predictions,
    this.categorie,
  });

  bool get peutEtreEnregistre => acidite != null && modeleUtiliseId != null;

  @override
  List<Object?> get props => [
        acidite,
        modeleUtiliseId,
        indicePeroxyde,
        conforme,
        dureeAnalyseSecondes,
        predictions,
        categorie,
      ];
}
