import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../analyseur/domain/entities/qualite_signal_entity.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';

/// Carte "Aperçu en Temps Réel" : masquée tant que l'acquisition n'a pas
/// démarré (voir NouvelleAnalyseScreen). Le spectre ET les 4 indicateurs de
/// qualité viennent TOUJOURS du signal réellement reçu (voir
/// analyseur/domain/services/calculateur_qualite_signal.dart) — aucune
/// valeur en dur.
class CarteApercuTempsReel extends StatelessWidget {
  final SpectreBrutEntity? spectre;
  final QualiteSignalEntity? qualite;

  const CarteApercuTempsReel({super.key, required this.spectre, required this.qualite});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = spectre?.points ?? const [];

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.podcasts, size: 20, color: AppColors.vertOliveFonce),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.carteApercuTempsReelTitre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ),
              if (qualite != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.evooFond,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart, size: 14, color: AppColors.vertOliveFonce),
                      const SizedBox(width: 4),
                      Text(l10n.signalQualiteLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: points.length < 2
                ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
                : _GraphiqueSpectre(points: points),
          ),
          if (qualite != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.grisLigne, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Indicateur(libelle: l10n.snrLabel, valeur: '${qualite!.snrDb} dB'),
                ),
                Expanded(
                  child: _Indicateur(
                      libelle: l10n.intensiteLabel, valeur: '${qualite!.intensitePourcentage.toInt()}%'),
                ),
                Expanded(
                  child: _Indicateur(libelle: l10n.bruitLabel, valeur: '${qualite!.bruit}'),
                ),
                Expanded(
                  child: _IndicateurCirculaire(
                    libelle: l10n.qualiteGlobaleLabel,
                    pourcentage: qualite!.qualiteGlobalePourcentage,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GraphiqueSpectre extends StatelessWidget {
  final List<PointSpectreEntity> points;

  const _GraphiqueSpectre({required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minX = points.first.longueurOndeNm;
    final maxX = points.last.longueurOndeNm;
    final valeurs = points.map((p) => p.absorbance);
    final minY = valeurs.reduce((a, b) => a < b ? a : b);
    final maxY = valeurs.reduce((a, b) => a > b ? a : b);
    final margeY = ((maxY - minY).abs() * 0.15).clamp(0.05, double.infinity);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY - margeY,
        maxY: maxY + margeY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.grisLigne, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (valeur, meta) => Text(
                valeur.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10, color: AppColors.grisMoyen),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(l10n.longueurOndeLabel,
                style: const TextStyle(fontSize: 10, color: AppColors.grisMoyen)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (valeur, meta) => Text(
                valeur.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: AppColors.grisMoyen),
              ),
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final p in points) FlSpot(p.longueurOndeNm, p.absorbance)],
            isCurved: true,
            color: AppColors.vertOlive,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.vertOlive.withValues(alpha: 0.25), AppColors.vertOlive.withValues(alpha: 0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicateur extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _Indicateur({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(valeur, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
      ],
    );
  }
}

class _IndicateurCirculaire extends StatelessWidget {
  final String libelle;
  final double pourcentage;

  const _IndicateurCirculaire({required this.libelle, required this.pourcentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: (pourcentage / 100).clamp(0, 1),
                strokeWidth: 3,
                backgroundColor: AppColors.grisLigne,
                color: AppColors.vertOlive,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${pourcentage.toInt()}%',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
            ),
          ],
        ),
      ],
    );
  }
}
