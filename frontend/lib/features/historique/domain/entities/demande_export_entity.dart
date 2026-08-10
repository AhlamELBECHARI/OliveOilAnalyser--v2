import 'package:equatable/equatable.dart';

import 'analyse_historique_entity.dart';

/// Correspond à `analyses.export.CONTENU_CHOICES` côté backend.
enum ContenuExport { resultats, spectres, lesDeux }

extension ContenuExportCode on ContenuExport {
  String get code => switch (this) {
        ContenuExport.resultats => 'resultats',
        ContenuExport.spectres => 'spectres',
        ContenuExport.lesDeux => 'les_deux',
      };
}

/// Corps de POST /api/analyses/export/. Deux modes de sélection mutuellement
/// exclusifs : soit [identifiants] explicites (sélection manuelle dans la
/// liste), soit [filtres] (mêmes filtres que l'écran Historique — "toutes
/// les analyses correspondant aux filtres actifs").
class DemandeExportEntity extends Equatable {
  final ContenuExport contenu;
  final String format;
  final List<String>? identifiants;
  final FiltresHistorique? filtres;

  const DemandeExportEntity({
    required this.contenu,
    required this.format,
    this.identifiants,
    this.filtres,
  });

  @override
  List<Object?> get props => [contenu, format, identifiants, filtres];
}
