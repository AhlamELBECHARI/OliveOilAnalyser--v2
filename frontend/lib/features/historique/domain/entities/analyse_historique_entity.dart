import 'package:equatable/equatable.dart';

/// Catégorie qualité dérivée côté backend (voir core.qualite côté Django) à
/// partir des seuils de Configuration — jamais recalculée côté mobile.
enum CategorieQualiteHistorique { evoo, voo, lampante }

CategorieQualiteHistorique categorieQualiteHistoriqueDepuisCode(String code) {
  switch (code) {
    case 'evoo':
      return CategorieQualiteHistorique.evoo;
    case 'voo':
      return CategorieQualiteHistorique.voo;
    default:
      return CategorieQualiteHistorique.lampante;
  }
}

/// Une ligne de la liste Historique, alimentée par GET /api/analyses/historique/
/// (analyses.services.rechercher_historique côté backend — recherche, filtres
/// et tri appliqués entièrement en base).
class AnalyseHistoriqueEntity extends Equatable {
  final String id;
  final String numeroEchantillon;
  final String producteurEchantillon;
  final String varieteEchantillon;
  final String regionEchantillon;
  final String origineEchantillon;
  final double acidite;
  final double indicePeroxyde;
  final DateTime dateCalcul;
  final bool conforme;
  final CategorieQualiteHistorique categorie;

  const AnalyseHistoriqueEntity({
    required this.id,
    required this.numeroEchantillon,
    required this.producteurEchantillon,
    required this.varieteEchantillon,
    required this.regionEchantillon,
    required this.origineEchantillon,
    required this.acidite,
    required this.indicePeroxyde,
    required this.dateCalcul,
    required this.conforme,
    required this.categorie,
  });

  @override
  List<Object?> get props => [
        id,
        numeroEchantillon,
        producteurEchantillon,
        varieteEchantillon,
        regionEchantillon,
        origineEchantillon,
        acidite,
        indicePeroxyde,
        dateCalcul,
        conforme,
        categorie,
      ];
}

/// Une page de résultats (voir core.pagination.PaginationStandard côté
/// backend) : [aPageSuivante] reflète directement la présence de `next`
/// dans la réponse DRF, pour piloter le bouton "Charger plus d'analyses".
class PageAnalysesHistorique extends Equatable {
  final List<AnalyseHistoriqueEntity> analyses;
  final bool aPageSuivante;
  final int total;

  const PageAnalysesHistorique({
    required this.analyses,
    required this.aPageSuivante,
    required this.total,
  });

  @override
  List<Object?> get props => [analyses, aPageSuivante, total];
}

/// Critères de recherche/filtrage de l'écran Historique — transmis tels
/// quels en paramètres de requête à GET /api/analyses/historique/, jamais
/// appliqués côté mobile.
class FiltresHistorique extends Equatable {
  final String? recherche;
  final String? qualite;
  final String? variete;
  final String? region;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  const FiltresHistorique({
    this.recherche,
    this.qualite,
    this.variete,
    this.region,
    this.dateDebut,
    this.dateFin,
  });

  bool get estVide =>
      (recherche == null || recherche!.isEmpty) &&
      qualite == null &&
      (variete == null || variete!.isEmpty) &&
      (region == null || region!.isEmpty) &&
      dateDebut == null &&
      dateFin == null;

  FiltresHistorique copierAvec({
    String? recherche,
    String? qualite,
    String? variete,
    String? region,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) {
    return FiltresHistorique(
      recherche: recherche ?? this.recherche,
      qualite: qualite ?? this.qualite,
      variete: variete ?? this.variete,
      region: region ?? this.region,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
    );
  }

  @override
  List<Object?> get props => [recherche, qualite, variete, region, dateDebut, dateFin];
}
