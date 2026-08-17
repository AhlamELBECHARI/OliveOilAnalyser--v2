import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Signale discrètement que les chiffres affichés proviennent du cache
/// local (calculés hors ligne) plutôt que du serveur — cahier des charges,
/// Partie A, section 3. Utilisé par DashboardScreen et HistoriqueScreen.
class BandeauDonneesLocales extends StatelessWidget {
  final String texte;

  const BandeauDonneesLocales({super.key, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orangeFond,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 14, color: AppColors.orangeIcone),
          const SizedBox(width: 6),
          Text(
            texte,
            style: AppTextStyles.sousTexteBienvenue.copyWith(
              fontSize: 11,
              color: AppColors.orangeIcone,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
