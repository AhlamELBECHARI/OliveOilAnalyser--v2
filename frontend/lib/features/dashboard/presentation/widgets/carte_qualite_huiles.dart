import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../../../core/widgets/carte_stylisee.dart';

Color _couleurCategorie(CategorieQualite categorie) {
  switch (categorie) {
    case CategorieQualite.evoo:
      return AppColors.evoo;
    case CategorieQualite.voo:
      return AppColors.voo;
    case CategorieQualite.lampante:
      return AppColors.lampante;
  }
}

/// Le libellé affiché vient toujours des fichiers ARB (via la catégorie),
/// jamais du champ `libelle` renvoyé par le backend (non traduisible).
String libelleCategorie(CategorieQualite categorie, AppLocalizations l10n) {
  switch (categorie) {
    case CategorieQualite.evoo:
      return l10n.categorieEvoo;
    case CategorieQualite.voo:
      return l10n.categorieVoo;
    case CategorieQualite.lampante:
      return l10n.categorieLampante;
  }
}

String libelleCourtCategorie(CategorieQualite categorie, AppLocalizations l10n) {
  switch (categorie) {
    case CategorieQualite.evoo:
      return l10n.categorieEvooCourt;
    case CategorieQualite.voo:
      return l10n.categorieVooCourt;
    case CategorieQualite.lampante:
      return l10n.categorieLampanteCourt;
  }
}

/// Carte "Qualité des huiles (ce mois)" : donut + légende avec pourcentage
/// et effectif par catégorie.
class CarteQualiteHuiles extends StatelessWidget {
  final List<RepartitionQualiteEntity> repartition;
  final VoidCallback? onVoirDetail;

  const CarteQualiteHuiles({super.key, required this.repartition, this.onVoirDetail});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = repartition.fold<int>(0, (m, r) => m + r.effectif);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.qualiteHuilesTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 42,
                        sections: [
                          for (final ligne in repartition)
                            if (ligne.effectif > 0)
                              PieChartSectionData(
                                value: ligne.effectif.toDouble(),
                                color: _couleurCategorie(ligne.categorie),
                                radius: 22,
                                showTitle: false,
                              ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.grisFonce,
                          ),
                        ),
                        Text(l10n.total, style: AppTextStyles.sousTexteBienvenue),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final ligne in repartition)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _couleurCategorie(ligne.categorie),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                libelleCategorie(ligne.categorie, l10n),
                                style: const TextStyle(fontSize: 13, color: AppColors.grisFonce),
                              ),
                            ),
                            Text(
                              '${ligne.pourcentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 13, color: AppColors.grisMoyen),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${ligne.effectif}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grisFonce,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onVoirDetail,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.voirRepartitionDetaillee,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.vertOlive),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.vertOlive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
