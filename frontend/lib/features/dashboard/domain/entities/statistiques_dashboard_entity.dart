import 'package:equatable/equatable.dart';

class MetriqueAvecVariationEntity extends Equatable {
  final int valeur;
  final double? variationPourcentage;

  const MetriqueAvecVariationEntity({required this.valeur, this.variationPourcentage});

  @override
  List<Object?> get props => [valeur, variationPourcentage];
}

class EchantillonsTotauxEntity extends Equatable {
  final int valeur;
  final int ajoutsCeMois;

  const EchantillonsTotauxEntity({required this.valeur, required this.ajoutsCeMois});

  @override
  List<Object?> get props => [valeur, ajoutsCeMois];
}

class TempsMoyenEntity extends Equatable {
  final double? valeur;
  final double? variationPourcentage;

  const TempsMoyenEntity({this.valeur, this.variationPourcentage});

  @override
  List<Object?> get props => [valeur, variationPourcentage];
}

class PointSerieEntity extends Equatable {
  final DateTime date;
  final int nombreAnalyses;

  const PointSerieEntity({required this.date, required this.nombreAnalyses});

  @override
  List<Object?> get props => [date, nombreAnalyses];
}

enum CategorieQualite { evoo, voo, lampante }

CategorieQualite categorieQualiteDepuisCode(String code) {
  switch (code) {
    case 'evoo':
      return CategorieQualite.evoo;
    case 'voo':
      return CategorieQualite.voo;
    default:
      return CategorieQualite.lampante;
  }
}

class RepartitionQualiteEntity extends Equatable {
  final CategorieQualite categorie;
  final String libelle;
  final int effectif;
  final double pourcentage;

  const RepartitionQualiteEntity({
    required this.categorie,
    required this.libelle,
    required this.effectif,
    required this.pourcentage,
  });

  @override
  List<Object?> get props => [categorie, libelle, effectif, pourcentage];
}

class AnalyseRecenteEntity extends Equatable {
  final String resultatId;
  final String numero;
  final String origine;
  final String variete;
  final String heure;
  final CategorieQualite categorie;

  const AnalyseRecenteEntity({
    required this.resultatId,
    required this.numero,
    required this.origine,
    required this.variete,
    required this.heure,
    required this.categorie,
  });

  @override
  List<Object?> get props => [resultatId, numero, origine, variete, heure, categorie];
}

class StatistiquesDashboardEntity extends Equatable {
  final String nomUtilisateur;
  final MetriqueAvecVariationEntity analysesCeMois;
  final EchantillonsTotauxEntity echantillonsTotaux;
  final MetriqueAvecVariationEntity analysesAujourdHui;
  final TempsMoyenEntity tempsMoyenParAnalyse;
  final List<PointSerieEntity> serie7Jours;
  final List<RepartitionQualiteEntity> repartitionQualite;
  final List<AnalyseRecenteEntity> analysesRecentes;

  const StatistiquesDashboardEntity({
    required this.nomUtilisateur,
    required this.analysesCeMois,
    required this.echantillonsTotaux,
    required this.analysesAujourdHui,
    required this.tempsMoyenParAnalyse,
    required this.serie7Jours,
    required this.repartitionQualite,
    required this.analysesRecentes,
  });

  @override
  List<Object?> get props => [
        nomUtilisateur,
        analysesCeMois,
        echantillonsTotaux,
        analysesAujourdHui,
        tempsMoyenParAnalyse,
        serie7Jours,
        repartitionQualite,
        analysesRecentes,
      ];
}
