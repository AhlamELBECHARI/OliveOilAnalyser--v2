import '../../domain/entities/statistiques_dashboard_entity.dart';

class MetriqueAvecVariationModel extends MetriqueAvecVariationEntity {
  const MetriqueAvecVariationModel({required super.valeur, super.variationPourcentage});

  factory MetriqueAvecVariationModel.fromJson(Map<String, dynamic> json) {
    return MetriqueAvecVariationModel(
      valeur: json['valeur'] as int,
      variationPourcentage: (json['variation_pourcentage'] as num?)?.toDouble(),
    );
  }
}

class EchantillonsTotauxModel extends EchantillonsTotauxEntity {
  const EchantillonsTotauxModel({required super.valeur, required super.ajoutsCeMois});

  factory EchantillonsTotauxModel.fromJson(Map<String, dynamic> json) {
    return EchantillonsTotauxModel(
      valeur: json['valeur'] as int,
      ajoutsCeMois: json['ajouts_ce_mois'] as int,
    );
  }
}

class TempsMoyenModel extends TempsMoyenEntity {
  const TempsMoyenModel({super.valeur, super.variationPourcentage});

  factory TempsMoyenModel.fromJson(Map<String, dynamic> json) {
    return TempsMoyenModel(
      valeur: (json['valeur'] as num?)?.toDouble(),
      variationPourcentage: (json['variation_pourcentage'] as num?)?.toDouble(),
    );
  }
}

class PointSerieModel extends PointSerieEntity {
  const PointSerieModel({required super.date, required super.nombreAnalyses});

  factory PointSerieModel.fromJson(Map<String, dynamic> json) {
    return PointSerieModel(
      date: DateTime.parse(json['date'] as String),
      nombreAnalyses: json['nombre_analyses'] as int,
    );
  }
}

class RepartitionQualiteModel extends RepartitionQualiteEntity {
  const RepartitionQualiteModel({
    required super.categorie,
    required super.libelle,
    required super.effectif,
    required super.pourcentage,
  });

  factory RepartitionQualiteModel.fromJson(Map<String, dynamic> json) {
    return RepartitionQualiteModel(
      categorie: categorieQualiteDepuisCode(json['categorie'] as String),
      libelle: json['libelle'] as String,
      effectif: json['effectif'] as int,
      pourcentage: (json['pourcentage'] as num).toDouble(),
    );
  }
}

class AnalyseRecenteModel extends AnalyseRecenteEntity {
  const AnalyseRecenteModel({
    required super.resultatId,
    required super.numero,
    required super.origine,
    required super.variete,
    required super.heure,
    required super.categorie,
  });

  factory AnalyseRecenteModel.fromJson(Map<String, dynamic> json) {
    return AnalyseRecenteModel(
      resultatId: json['resultat_id'] as String,
      numero: json['numero'] as String,
      origine: json['origine'] as String,
      variete: json['variete'] as String,
      heure: json['heure'] as String,
      categorie: categorieQualiteDepuisCode(json['categorie'] as String),
    );
  }
}

class StatistiquesDashboardModel extends StatistiquesDashboardEntity {
  const StatistiquesDashboardModel({
    required super.nomUtilisateur,
    required super.analysesCeMois,
    required super.echantillonsTotaux,
    required super.analysesAujourdHui,
    required super.tempsMoyenParAnalyse,
    required super.serie7Jours,
    required super.repartitionQualite,
    required super.analysesRecentes,
  });

  factory StatistiquesDashboardModel.fromJson(Map<String, dynamic> json) {
    return StatistiquesDashboardModel(
      nomUtilisateur: json['nom_utilisateur'] as String,
      analysesCeMois: MetriqueAvecVariationModel.fromJson(
        json['analyses_ce_mois'] as Map<String, dynamic>,
      ),
      echantillonsTotaux: EchantillonsTotauxModel.fromJson(
        json['echantillons_totaux'] as Map<String, dynamic>,
      ),
      analysesAujourdHui: MetriqueAvecVariationModel.fromJson(
        json['analyses_aujourd_hui'] as Map<String, dynamic>,
      ),
      tempsMoyenParAnalyse: TempsMoyenModel.fromJson(
        json['temps_moyen_par_analyse_minutes'] as Map<String, dynamic>,
      ),
      serie7Jours: (json['serie_7_jours'] as List)
          .map((e) => PointSerieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      repartitionQualite: (json['repartition_qualite'] as List)
          .map((e) => RepartitionQualiteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysesRecentes: (json['analyses_recentes'] as List)
          .map((e) => AnalyseRecenteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
