import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import 'carte_apercu_historique.dart';

/// Une ligne de la liste Historique (design/4-historiques.png) : icône
/// colorée par catégorie qualité, ID, "Producteur • Variété", date/heure,
/// région, badge catégorie, acidité, PASS/FAIL, chevron.
class CarteAnalyseHistorique extends StatelessWidget {
  final AnalyseHistoriqueEntity analyse;
  final VoidCallback onTap;

  const CarteAnalyseHistorique({super.key, required this.analyse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final couleur = couleurCategorie(analyse.categorie);
    final formatAcidite = NumberFormat('#,##0.000', l10n.localeName);
    final dateFormatee = DateFormat.MMMd(l10n.localeName).add_Hm().format(analyse.dateCalcul);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CarteStylisee(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fondCategorie(analyse.categorie), shape: BoxShape.circle),
              child: Icon(Icons.water_drop_outlined, color: couleur, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analyse.numeroEchantillon,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${analyse.producteurEchantillon} • ${analyse.varieteEchantillon}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateFormatee • ${analyse.regionEchantillon}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${l10n.acidite} ${formatAcidite.format(analyse.acidite)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grisMoyen),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (analyse.conforme ? AppColors.succes : AppColors.erreur).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    analyse.conforme ? l10n.conforme : l10n.nonConforme,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: analyse.conforme ? AppColors.succes : AppColors.erreur,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.grisClair),
          ],
        ),
      ),
    );
  }
}
