import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';

/// Carte "Statistiques rapides" : 4 mini-graphiques (design/4-historiques.png),
/// chacun alimenté par une série pré-calculée côté backend (voir
/// analyses.services.obtenir_statistiques_rapides) — jamais de calcul de
/// tendance côté mobile.
class CarteStatistiquesRapides extends StatelessWidget {
  final IndicateurAvecSerieEntity tendanceAciditeMoyenne;
  final IndicateurAvecSerieEntity meilleureQualite;
  final IndicateurAvecSerieEntity plusForteAcidite;
  final IndicateurAvecSerieEntity analysesParJour;

  const CarteStatistiquesRapides({
    super.key,
    required this.tendanceAciditeMoyenne,
    required this.meilleureQualite,
    required this.plusForteAcidite,
    required this.analysesParJour,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistiquesRapidesTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _MiniGraphique(
                libelle: l10n.tendanceAciditeMoyenneLabel,
                indicateur: tendanceAciditeMoyenne,
                couleur: AppColors.vertOlive,
                suffixe: '%',
              ),
              _MiniGraphique(
                libelle: l10n.meilleureQualiteLabel,
                indicateur: meilleureQualite,
                couleur: AppColors.bleuIcone,
                suffixe: '%',
              ),
              _MiniGraphique(
                libelle: l10n.plusForteAciditeLabel,
                indicateur: plusForteAcidite,
                couleur: AppColors.lampante,
                suffixe: '%',
              ),
              _MiniGraphique(
                libelle: l10n.analysesParJourLabel,
                indicateur: analysesParJour,
                couleur: AppColors.orangeIcone,
                suffixe: '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniGraphique extends StatelessWidget {
  final String libelle;
  final IndicateurAvecSerieEntity indicateur;
  final Color couleur;
  final String suffixe;

  const _MiniGraphique({
    required this.libelle,
    required this.indicateur,
    required this.couleur,
    required this.suffixe,
  });

  @override
  Widget build(BuildContext context) {
    final points = <FlSpot>[];
    for (var i = 0; i < indicateur.serie.length; i++) {
      final valeur = indicateur.serie[i].valeur;
      if (valeur != null) points.add(FlSpot(i.toDouble(), valeur));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.fond, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            libelle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            indicateur.valeur != null ? '${indicateur.valeur!.toStringAsFixed(2)}$suffixe' : '—',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: points.length < 2
                ? const SizedBox.shrink()
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points,
                          isCurved: true,
                          color: couleur,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: couleur.withValues(alpha: 0.12)),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
