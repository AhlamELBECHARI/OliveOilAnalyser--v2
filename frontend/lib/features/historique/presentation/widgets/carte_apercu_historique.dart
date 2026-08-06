import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';

Color couleurCategorie(CategorieQualiteHistorique categorie) => switch (categorie) {
      CategorieQualiteHistorique.evoo => AppColors.evoo,
      CategorieQualiteHistorique.voo => AppColors.voo,
      CategorieQualiteHistorique.lampante => AppColors.lampante,
    };

Color fondCategorie(CategorieQualiteHistorique categorie) => switch (categorie) {
      CategorieQualiteHistorique.evoo => AppColors.evooFond,
      CategorieQualiteHistorique.voo => AppColors.vooFond,
      CategorieQualiteHistorique.lampante => AppColors.lampanteFond,
    };

/// Carte "Aperçu" (design/4-historiques.png) : 5 indicateurs — total,
/// répartition qualité (3), et analyses ce mois — tous depuis GET
/// /api/analyses/statistiques-rapides/, jamais recalculés côté mobile.
class CarteApercuHistorique extends StatelessWidget {
  final ApercuHistoriqueEntity apercu;

  const CarteApercuHistorique({super.key, required this.apercu});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatNombre = NumberFormat.decimalPattern(l10n.localeName);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.apercuTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: [
              _Indicateur(
                icone: Icons.science_outlined,
                couleur: AppColors.bleuIcone,
                fond: AppColors.bleuFond,
                libelle: l10n.totalAnalysesLabel,
                valeur: formatNombre.format(apercu.totalAnalyses),
              ),
              _Indicateur(
                icone: Icons.calendar_today_outlined,
                couleur: AppColors.orangeIcone,
                fond: AppColors.orangeFond,
                libelle: l10n.ceMoisLabel,
                valeur: formatNombre.format(apercu.ceMois.valeur),
              ),
              for (final item in apercu.repartitionQualite)
                _Indicateur(
                  icone: Icons.water_drop_outlined,
                  couleur: couleurCategorie(item.categorie),
                  fond: fondCategorie(item.categorie),
                  libelle: item.libelle,
                  valeur: '${formatNombre.format(item.effectif)} (${item.pourcentage.toStringAsFixed(0)}%)',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Indicateur extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String libelle;
  final String valeur;

  const _Indicateur({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.libelle,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icon(icone, color: couleur, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valeur,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
              ),
              Text(
                libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
