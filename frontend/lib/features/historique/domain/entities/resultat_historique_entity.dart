import 'package:equatable/equatable.dart';

/// Une prédiction d'un modèle pour ce résultat (voir
/// resultats.models.PredictionModele côté backend) — plusieurs modèles
/// évaluent le même scan simultanément (régression et classification).
class PredictionHistoriqueEntity extends Equatable {
  final int modeleId;
  final String modeleNom;
  final String modeleVersion;
  final String typeModele; // 'regression' | 'classification'
  final String grandeurPredite; // 'acidite' | 'indice_peroxyde' | 'authenticite'
  final double? valeurNumerique;
  final String? classePredite; // 'pure' | 'melangee'
  final double? scoreConfiance;

  const PredictionHistoriqueEntity({
    required this.modeleId,
    required this.modeleNom,
    required this.modeleVersion,
    required this.typeModele,
    required this.grandeurPredite,
    required this.valeurNumerique,
    required this.classePredite,
    required this.scoreConfiance,
  });

  @override
  List<Object?> get props => [
        modeleId,
        modeleNom,
        modeleVersion,
        typeModele,
        grandeurPredite,
        valeurNumerique,
        classePredite,
        scoreConfiance,
      ];
}

class ResultatHistoriqueEntity extends Equatable {
  final String id;
  final String echantillonId;
  final int numeroReplicat;
  final String numeroEchantillon;
  final String varieteEchantillon;
  final String origineEchantillon;
  final String producteurEchantillon;
  final String regionEchantillon;
  // Toujours renvoyés par l'API (voir ResultatSerializer côté backend),
  // utiles seulement côté admin — voir ResultatDetailScreen.
  final int auteurId;
  final String auteurNom;
  final double acidite;
  final double indicePeroxyde;
  final int? dureeAnalyseSecondes;
  final DateTime dateCalcul;
  final bool conforme;
  final String commentaire;
  final List<PredictionHistoriqueEntity> predictions;
  // Valeurs mesurées a posteriori au laboratoire, saisies manuellement —
  // `null`/vide tant qu'aucune mesure n'a été renseignée pour ce résultat.
  final double? aciditeReference;
  final double? indicePeroxydeReference;
  final String? authenticiteReference; // 'pure' | 'melangee'
  final DateTime? dateMesureReference;

  const ResultatHistoriqueEntity({
    required this.id,
    required this.echantillonId,
    required this.numeroReplicat,
    required this.numeroEchantillon,
    required this.varieteEchantillon,
    required this.origineEchantillon,
    required this.producteurEchantillon,
    required this.regionEchantillon,
    required this.auteurId,
    required this.auteurNom,
    required this.acidite,
    required this.indicePeroxyde,
    required this.dureeAnalyseSecondes,
    required this.dateCalcul,
    required this.conforme,
    required this.commentaire,
    required this.predictions,
    required this.aciditeReference,
    required this.indicePeroxydeReference,
    required this.authenticiteReference,
    required this.dateMesureReference,
  });

  bool get aDesValeursReference =>
      aciditeReference != null || indicePeroxydeReference != null || authenticiteReference != null;

  @override
  List<Object?> get props => [
        id,
        echantillonId,
        numeroReplicat,
        numeroEchantillon,
        varieteEchantillon,
        origineEchantillon,
        producteurEchantillon,
        regionEchantillon,
        auteurId,
        auteurNom,
        acidite,
        indicePeroxyde,
        dureeAnalyseSecondes,
        dateCalcul,
        conforme,
        commentaire,
        predictions,
        aciditeReference,
        indicePeroxydeReference,
        authenticiteReference,
        dateMesureReference,
      ];
}
