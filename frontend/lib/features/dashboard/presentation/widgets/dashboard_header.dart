import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// En-tête du dashboard : logo + nom de l'app, boutons notifications/scan,
/// message de bienvenue avec le nom réel de l'utilisateur connecté, et date
/// du jour formatée selon la locale active.
class DashboardHeader extends StatelessWidget {
  final String nomUtilisateur;
  final int alertesNonLues;
  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapScan;

  const DashboardHeader({
    super.key,
    required this.nomUtilisateur,
    required this.alertesNonLues,
    this.onTapNotifications,
    this.onTapScan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateDuJour = DateFormat.yMMMMEEEEd(l10n.localeName).format(DateTime.now());
    final dateCapitalisee = dateDuJour[0].toUpperCase() + dateDuJour.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/oliveIQ_logo.png', width: 36, height: 36),
                const SizedBox(width: 8),
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.vertOliveFonce,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _BoutonCarre(
                  icone: Icons.notifications_outlined,
                  pastille: alertesNonLues > 0,
                  onTap: onTapNotifications,
                ),
                const SizedBox(width: 12),
                _BoutonCarre(icone: Icons.qr_code_scanner, onTap: onTapScan),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(l10n.bonjour, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.grisFonce)),
        Text(nomUtilisateur, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 16)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grisMoyen),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                dateCapitalisee,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoutonCarre extends StatelessWidget {
  final IconData icone;
  final bool pastille;
  final VoidCallback? onTap;

  const _BoutonCarre({required this.icone, this.pastille = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grisLigne),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icone, color: AppColors.grisFonce, size: 22),
            if (pastille)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.succes, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
