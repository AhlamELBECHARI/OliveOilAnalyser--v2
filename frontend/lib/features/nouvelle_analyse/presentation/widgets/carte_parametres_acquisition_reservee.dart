import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';

/// Emplacement RÉSERVÉ pour la carte "Paramètres d'Acquisition" de
/// design/3-analyse.png (gamme spectrale, résolution, moyennes, mode,
/// référence). Volontairement non implémentée : ces réglages dépendent du
/// protocole exact du spectromètre, pas encore documenté par le fabricant
/// (voir data/protocole/protocole_spectrometre.dart dans la feature
/// analyseur). Cette carte occupe déjà sa place dans la mise en page,
/// visuellement désactivée, pour qu'un futur ajout ne demande aucun
/// réagencement de l'écran.
class CarteParametresAcquisitionReservee extends StatelessWidget {
  const CarteParametresAcquisitionReservee({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Opacity(
      opacity: 0.5,
      child: CarteStylisee(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, size: 20, color: AppColors.grisMoyen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.carteParametresAcquisitionTitre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grisMoyen),
                  ),
                ),
                const Icon(Icons.lock_outline, size: 16, color: AppColors.grisMoyen),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.parametresAcquisitionIndisponible, style: AppTextStyles.sousTexteBienvenue),
          ],
        ),
      ),
    );
  }
}
