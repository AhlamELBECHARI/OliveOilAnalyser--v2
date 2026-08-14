import '../../domain/entities/analyse_historique_entity.dart';

class AnalyseHistoriqueModel extends AnalyseHistoriqueEntity {
  const AnalyseHistoriqueModel({
    required super.id,
    required super.numeroEchantillon,
    required super.producteurEchantillon,
    required super.varieteEchantillon,
    required super.regionEchantillon,
    required super.origineEchantillon,
    required super.acidite,
    required super.indicePeroxyde,
    required super.dateCalcul,
    required super.conforme,
    required super.categorie,
    required super.auteurId,
    required super.auteurNom,
  });

  factory AnalyseHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return AnalyseHistoriqueModel(
      id: json['id'] as String,
      numeroEchantillon: json['numero_echantillon'] as String,
      producteurEchantillon: json['producteur_echantillon'] as String,
      varieteEchantillon: json['variete_echantillon'] as String,
      regionEchantillon: json['region_echantillon'] as String,
      origineEchantillon: json['origine_echantillon'] as String,
      acidite: double.parse(json['acidite'] as String),
      indicePeroxyde: double.parse(json['indice_peroxyde'] as String),
      dateCalcul: DateTime.parse(json['date_calcul'] as String),
      conforme: json['conforme'] as bool,
      categorie: categorieQualiteHistoriqueDepuisCode(json['categorie'] as String),
      auteurId: json['auteur_id'] as int,
      auteurNom: json['auteur_nom'] as String,
    );
  }
}
