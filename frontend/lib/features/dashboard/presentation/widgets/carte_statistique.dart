import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';

/// Une carte de statistique de la grille 2x2 (Analyses ce mois, Échantillons
/// totaux, Analyses aujourd'hui, Temps moyen / analyse).
class CarteStatistique extends StatelessWidget {
  final IconData icone;
  final Color couleurIcone;
  final Color fondIcone;
  final String libelle;
  final String valeur;
  final String? variationTexte;
  final bool? variationPositive;

  const CarteStatistique({
    super.key,
    required this.icone,
    required this.couleurIcone,
    required this.fondIcone,
    required this.libelle,
    required this.valeur,
    this.variationTexte,
    this.variationPositive,
  });

  @override
  Widget build(BuildContext context) {
    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: fondIcone, shape: BoxShape.circle),
            child: Icon(icone, color: couleurIcone, size: 20),
          ),
          const SizedBox(height: 12),
          Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            valeur,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
          ),
          if (variationTexte != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  variationPositive == true ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: variationPositive == true ? AppColors.succes : AppColors.grisMoyen,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    variationTexte!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: variationPositive == true ? AppColors.succes : AppColors.grisMoyen,
                    ),
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
