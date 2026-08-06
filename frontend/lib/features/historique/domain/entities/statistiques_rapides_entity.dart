import 'package:equatable/equatable.dart';

import 'analyse_historique_entity.dart';

/// Alimente la carte "Aperçu" (5 indicateurs) de l'écran Historique — voir
/// GET /api/analyses/statistiques-rapides/ (analyses.services.obtenir_apercu).
class RepartitionQualiteItemEntity extends Equatable {
  final CategorieQualiteHistorique categorie;
  final String libelle;
  final int effectif;
  final double pourcentage;

  const RepartitionQualiteItemEntity({
    required this.categorie,
    required this.libelle,
    required this.effectif,
    required this.pourcentage,
  });

  @override
  List<Object?> get props => [categorie, libelle, effectif, pourcentage];
}

class IndicateurEntierEntity extends Equatable {
  final int valeur;
  final double? variationPourcentage;

  const IndicateurEntierEntity({required this.valeur, this.variationPourcentage});

  @override
  List<Object?> get props => [valeur, variationPourcentage];
}

class ApercuHistoriqueEntity extends Equatable {
  final int totalAnalyses;
  final List<RepartitionQualiteItemEntity> repartitionQualite;
  final IndicateurEntierEntity ceMois;

  const ApercuHistoriqueEntity({
    required this.totalAnalyses,
    required this.repartitionQualite,
    required this.ceMois,
  });

  @override
  List<Object?> get props => [totalAnalyses, repartitionQualite, ceMois];
}

/// Un point des mini-graphiques de tendance ("Statistiques rapides").
class PointSerieValeurEntity extends Equatable {
  final String date;
  final double? valeur;

  const PointSerieValeurEntity({required this.date, this.valeur});

  @override
  List<Object?> get props => [date, valeur];
}

class IndicateurAvecSerieEntity extends Equatable {
  final double? valeur;
  final double? variationPourcentage;
  final List<PointSerieValeurEntity> serie;

  const IndicateurAvecSerieEntity({this.valeur, this.variationPourcentage, required this.serie});

  @override
  List<Object?> get props => [valeur, variationPourcentage, serie];
}

/// Les 5 indicateurs "Aperçu" + les 4 mini-graphiques "Statistiques
/// rapides" de design/4-historiques.png, en une seule agrégation ORM
/// côté backend (analyses.services.obtenir_statistiques_rapides).
class StatistiquesRapidesEntity extends Equatable {
  final ApercuHistoriqueEntity apercu;
  final IndicateurAvecSerieEntity tendanceAciditeMoyenne;
  final IndicateurAvecSerieEntity meilleureQualite;
  final IndicateurAvecSerieEntity plusForteAcidite;
  final IndicateurAvecSerieEntity analysesParJour;

  const StatistiquesRapidesEntity({
    required this.apercu,
    required this.tendanceAciditeMoyenne,
    required this.meilleureQualite,
    required this.plusForteAcidite,
    required this.analysesParJour,
  });

  @override
  List<Object?> get props =>
      [apercu, tendanceAciditeMoyenne, meilleureQualite, plusForteAcidite, analysesParJour];
}
