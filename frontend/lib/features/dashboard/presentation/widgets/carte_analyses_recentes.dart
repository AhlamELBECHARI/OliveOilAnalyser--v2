import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../../../core/widgets/carte_stylisee.dart';

/// Carte "Analyses récentes (7 derniers jours)" : graphique en barres,
/// valeur affichée au-dessus de chaque barre, jours en abscisse.
class CarteAnalysesRecentes extends StatelessWidget {
  final List<PointSerieEntity> serie;

  const CarteAnalysesRecentes({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxValeur = serie.fold<int>(0, (m, p) => p.nombreAnalyses > m ? p.nombreAnalyses : m);
    // Graduation de l'axe Y arrondie au multiple de 10 supérieur (min 10).
    final plafond = (((maxValeur == 0 ? 1 : maxValeur) / 10).ceil() * 10).clamp(10, 1000000).toDouble();

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.analysesRecentesTitre,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ),
              const SizedBox(width: 8),
              _SelecteurPeriode(texte: l10n.septJours),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: plafond,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: plafond / 4,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.grisLigne, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: plafond / 4,
                      reservedSize: 28,
                      getTitlesWidget: (valeur, meta) => Text(
                        valeur.toInt().toString(),
                        style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (valeur, meta) {
                        final index = valeur.toInt();
                        if (index < 0 || index >= serie.length) return const SizedBox.shrink();
                        final date = serie[index].date;
                        final jour = DateFormat.E(l10n.localeName).format(date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '$jour ${date.day}',
                            style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      rod.toY.toInt().toString(),
                      const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grisFonce,
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < serie.length; i++)
                    BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: [0],
                      barRods: [
                        BarChartRodData(
                          toY: serie[i].nombreAnalyses.toDouble(),
                          color: AppColors.vertOlive,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
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

class _SelecteurPeriode extends StatelessWidget {
  final String texte;

  const _SelecteurPeriode({required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grisLigne),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texte, style: const TextStyle(fontSize: 13, color: AppColors.grisFonce)),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.grisMoyen),
        ],
      ),
    );
  }
}
