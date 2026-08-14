import '../../domain/entities/resultat_historique_entity.dart';

class PredictionHistoriqueModel extends PredictionHistoriqueEntity {
  const PredictionHistoriqueModel({
    required super.modeleId,
    required super.modeleNom,
    required super.modeleVersion,
    required super.typeModele,
    required super.grandeurPredite,
    required super.valeurNumerique,
    required super.classePredite,
    required super.scoreConfiance,
  });

  factory PredictionHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return PredictionHistoriqueModel(
      modeleId: json['modele'] as int,
      modeleNom: json['modele_nom'] as String,
      modeleVersion: json['modele_version'] as String,
      typeModele: json['type_modele'] as String,
      grandeurPredite: json['grandeur_predite'] as String,
      valeurNumerique: json['valeur_numerique'] == null
          ? null
          : double.parse(json['valeur_numerique'] as String),
      classePredite: (json['classe_predite'] as String?)?.isEmpty ?? true
          ? null
          : json['classe_predite'] as String,
      scoreConfiance: (json['score_confiance'] as num?)?.toDouble(),
    );
  }
}

class ResultatHistoriqueModel extends ResultatHistoriqueEntity {
  const ResultatHistoriqueModel({
    required super.id,
    required super.echantillonId,
    required super.numeroReplicat,
    required super.numeroEchantillon,
    required super.varieteEchantillon,
    required super.origineEchantillon,
    required super.producteurEchantillon,
    required super.regionEchantillon,
    required super.auteurId,
    required super.auteurNom,
    required super.acidite,
    required super.indicePeroxyde,
    required super.dureeAnalyseSecondes,
    required super.dateCalcul,
    required super.conforme,
    required super.commentaire,
    required super.predictions,
    required super.aciditeReference,
    required super.indicePeroxydeReference,
    required super.authenticiteReference,
    required super.dateMesureReference,
  });

  factory ResultatHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return ResultatHistoriqueModel(
      id: json['id'] as String,
      echantillonId: json['echantillon'] as String,
      numeroReplicat: json['numero_replicat'] as int,
      numeroEchantillon: json['numero_echantillon'] as String,
      varieteEchantillon: json['variete_echantillon'] as String,
      origineEchantillon: json['origine_echantillon'] as String,
      producteurEchantillon: json['producteur_echantillon'] as String,
      regionEchantillon: json['region_echantillon'] as String,
      auteurId: json['auteur_id'] as int,
      auteurNom: json['auteur_nom'] as String,
      acidite: double.parse(json['acidite'] as String),
      indicePeroxyde: double.parse(json['indice_peroxyde'] as String),
      dureeAnalyseSecondes: json['duree_analyse_secondes'] as int?,
      dateCalcul: DateTime.parse(json['date_calcul'] as String),
      conforme: json['conforme'] as bool,
      commentaire: json['commentaire'] as String,
      predictions: (json['predictions'] as List? ?? [])
          .map((e) => PredictionHistoriqueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      aciditeReference: json['acidite_reference'] == null
          ? null
          : double.parse(json['acidite_reference'] as String),
      indicePeroxydeReference: json['indice_peroxyde_reference'] == null
          ? null
          : double.parse(json['indice_peroxyde_reference'] as String),
      authenticiteReference: (json['authenticite_reference'] as String?)?.isEmpty ?? true
          ? null
          : json['authenticite_reference'] as String,
      dateMesureReference: json['date_mesure_reference'] == null
          ? null
          : DateTime.parse(json['date_mesure_reference'] as String),
    );
  }
}
