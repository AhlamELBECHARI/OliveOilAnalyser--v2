import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../providers/historique_provider.dart';
import 'resultat_detail_screen.dart';

/// Historique complet des analyses, alimenté par GET /api/resultats/.
class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(historiqueProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.navHistorique, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, HistoriqueState state) {
    final l10n = context.l10n;

    if (state.resultats == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.resultats == null && state.echec != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.grisMoyen),
              const SizedBox(height: 16),
              Text(
                state.echec!.messageLocalise(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                onPressed: () => ref.read(historiqueProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final resultats = state.resultats ?? const [];

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(historiqueProvider.notifier).charger(),
      child: resultats.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    l10n.aucunResultat,
                    style: AppTextStyles.sousTexteBienvenue,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: resultats.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CarteResultat(resultat: resultats[index]),
            ),
    );
  }
}

class _CarteResultat extends StatelessWidget {
  final ResultatHistoriqueEntity resultat;

  const _CarteResultat({required this.resultat});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatAcidite = NumberFormat('#,##0.000', l10n.localeName);
    final dateFormatee = DateFormat.yMMMd(l10n.localeName).add_Hm().format(resultat.dateCalcul);
    final couleur = resultat.conforme ? AppColors.succes : AppColors.erreur;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultatDetailScreen(resultatId: resultat.id)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: CarteStylisee(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resultat.numeroEchantillon,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${resultat.origineEchantillon} • ${resultat.varieteEchantillon}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(dateFormatee, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${l10n.acidite} ${formatAcidite.format(resultat.acidite)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grisMoyen),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    resultat.conforme ? l10n.conforme : l10n.nonConforme,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur),
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
