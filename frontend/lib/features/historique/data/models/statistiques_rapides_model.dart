import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';

class RepartitionQualiteItemModel extends RepartitionQualiteItemEntity {
  const RepartitionQualiteItemModel({
    required super.categorie,
    required super.libelle,
    required super.effectif,
    required super.pourcentage,
  });

  factory RepartitionQualiteItemModel.fromJson(Map<String, dynamic> json) {
    return RepartitionQualiteItemModel(
      categorie: categorieQualiteHistoriqueDepuisCode(json['categorie'] as String),
      libelle: json['libelle'] as String,
      effectif: json['effectif'] as int,
      pourcentage: (json['pourcentage'] as num).toDouble(),
    );
  }
}

class IndicateurEntierModel extends IndicateurEntierEntity {
  const IndicateurEntierModel({required super.valeur, super.variationPourcentage});

  factory IndicateurEntierModel.fromJson(Map<String, dynamic> json) {
    return IndicateurEntierModel(
      valeur: json['valeur'] as int,
      variationPourcentage: (json['variation_pourcentage'] as num?)?.toDouble(),
    );
  }
}

class ApercuHistoriqueModel extends ApercuHistoriqueEntity {
  const ApercuHistoriqueModel({
    required super.totalAnalyses,
    required super.repartitionQualite,
    required super.ceMois,
  });

  factory ApercuHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return ApercuHistoriqueModel(
      totalAnalyses: json['total_analyses'] as int,
      repartitionQualite: (json['repartition_qualite'] as List)
          .map((e) => RepartitionQualiteItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ceMois: IndicateurEntierModel.fromJson(json['ce_mois'] as Map<String, dynamic>),
    );
  }
}

class PointSerieValeurModel extends PointSerieValeurEntity {
  const PointSerieValeurModel({required super.date, super.valeur});

  factory PointSerieValeurModel.fromJson(Map<String, dynamic> json) {
    return PointSerieValeurModel(
      date: json['date'] as String,
      valeur: (json['valeur'] as num?)?.toDouble(),
    );
  }
}

class IndicateurAvecSerieModel extends IndicateurAvecSerieEntity {
  const IndicateurAvecSerieModel({super.valeur, super.variationPourcentage, required super.serie});

  factory IndicateurAvecSerieModel.fromJson(Map<String, dynamic> json) {
    return IndicateurAvecSerieModel(
      valeur: (json['valeur'] as num?)?.toDouble(),
      variationPourcentage: (json['variation_pourcentage'] as num?)?.toDouble(),
      serie: (json['serie'] as List)
          .map((e) => PointSerieValeurModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StatistiquesRapidesModel extends StatistiquesRapidesEntity {
  const StatistiquesRapidesModel({
    required super.apercu,
    required super.tendanceAciditeMoyenne,
    required super.meilleureQualite,
    required super.plusForteAcidite,
    required super.analysesParJour,
  });

  factory StatistiquesRapidesModel.fromJson(Map<String, dynamic> json) {
    return StatistiquesRapidesModel(
      apercu: ApercuHistoriqueModel.fromJson(json['apercu'] as Map<String, dynamic>),
      tendanceAciditeMoyenne: IndicateurAvecSerieModel.fromJson(
        json['tendance_acidite_moyenne'] as Map<String, dynamic>,
      ),
      meilleureQualite:
          IndicateurAvecSerieModel.fromJson(json['meilleure_qualite'] as Map<String, dynamic>),
      plusForteAcidite:
          IndicateurAvecSerieModel.fromJson(json['plus_forte_acidite'] as Map<String, dynamic>),
      analysesParJour:
          IndicateurAvecSerieModel.fromJson(json['analyses_par_jour'] as Map<String, dynamic>),
    );
  }
}
