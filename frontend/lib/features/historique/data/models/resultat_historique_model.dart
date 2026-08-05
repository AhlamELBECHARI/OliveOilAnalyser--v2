import '../../domain/entities/resultat_historique_entity.dart';

class ResultatHistoriqueModel extends ResultatHistoriqueEntity {
  const ResultatHistoriqueModel({
    required super.id,
    required super.numeroEchantillon,
    required super.varieteEchantillon,
    required super.origineEchantillon,
    required super.acidite,
    required super.indicePeroxyde,
    required super.dureeAnalyseSecondes,
    required super.dateCalcul,
    required super.conforme,
    required super.commentaire,
  });

  factory ResultatHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return ResultatHistoriqueModel(
      id: json['id'] as String,
      numeroEchantillon: json['numero_echantillon'] as String,
      varieteEchantillon: json['variete_echantillon'] as String,
      origineEchantillon: json['origine_echantillon'] as String,
      acidite: double.parse(json['acidite'] as String),
      indicePeroxyde: double.parse(json['indice_peroxyde'] as String),
      dureeAnalyseSecondes: json['duree_analyse_secondes'] as int?,
      dateCalcul: DateTime.parse(json['date_calcul'] as String),
      conforme: json['conforme'] as bool,
      commentaire: json['commentaire'] as String,
    );
  }
}
