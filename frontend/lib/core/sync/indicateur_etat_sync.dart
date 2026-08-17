import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../localization/build_context_l10n_extension.dart';
import '../network/connectivite_provider.dart';
import '../theme/app_colors.dart';
import 'synchronisation_provider.dart';

/// Indicateur global d'état réseau/synchronisation (cahier des charges,
/// Partie A, section 5), visible depuis n'importe quel écran : affiché une
/// seule fois par coquille de navigation (voir CoquilleNavigation /
/// CoquilleNavigationAdmin), jamais dupliqué par écran. Tap → écran "File
/// d'attente" (Paramètres) pour le détail et la relance manuelle.
class IndicateurEtatSync extends ConsumerWidget {
  const IndicateurEtatSync({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enLigne = ref.watch(connectiviteProvider).valueOrNull ?? true;
    final enCours = ref.watch(synchronisationEnCoursProvider).valueOrNull ?? false;
    final enAttente = ref.watch(elementsEnAttenteSyncProvider).valueOrNull ?? 0;

    final Color couleur;
    final IconData icone;
    final String texte;
    if (!enLigne) {
      couleur = AppColors.grisMoyen;
      icone = Icons.cloud_off_outlined;
      texte = enAttente > 0 ? l10n.etatHorsLigneAvecAttente(enAttente) : l10n.etatHorsLigne;
    } else if (enCours) {
      couleur = AppColors.bleuIcone;
      icone = Icons.sync;
      texte = l10n.etatSynchronisationEnCours;
    } else if (enAttente > 0) {
      couleur = AppColors.orangeIcone;
      icone = Icons.cloud_upload_outlined;
      texte = l10n.etatEnAttenteDeSynchronisation(enAttente);
    } else {
      couleur = AppColors.succes;
      icone = Icons.cloud_done_outlined;
      texte = l10n.etatEnLigne;
    }

    return InkWell(
      onTap: () => context.push('/synchronisation/file-attente'),
      child: Container(
        width: double.infinity,
        color: couleur.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 14, color: couleur),
            const SizedBox(width: 6),
            Text(
              texte,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: couleur),
            ),
          ],
        ),
      ),
    );
  }
}
