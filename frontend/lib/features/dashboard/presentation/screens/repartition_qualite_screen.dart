import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../widgets/carte_qualite_huiles.dart' show libelleCategorie;

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

/// Détail de la répartition qualité déjà chargée par le dashboard (mêmes
/// données que la carte "Qualité des huiles", pas de second appel réseau).
class RepartitionQualiteScreen extends StatelessWidget {
  final List<RepartitionQualiteEntity> repartition;

  const RepartitionQualiteScreen({super.key, required this.repartition});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatPourcentage = NumberFormat('#,##0.0', l10n.localeName);
    final total = repartition.fold<int>(0, (m, r) => m + r.effectif);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.qualiteHuilesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final ligne in repartition) ...[
            CarteStylisee(
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _couleurCategorie(ligne.categorie),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      libelleCategorie(ligne.categorie, l10n),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.grisFonce),
                    ),
                  ),
                  Text(
                    '${formatPourcentage.format(ligne.pourcentage)}%',
                    style: const TextStyle(fontSize: 14, color: AppColors.grisMoyen),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${ligne.effectif}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: AppTextStyles.sousTexteBienvenue),
                Text(
                  '$total',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
