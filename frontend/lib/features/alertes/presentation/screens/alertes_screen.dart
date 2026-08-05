import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/alerte_entity.dart';
import '../providers/alertes_provider.dart';

/// Liste des alertes de l'utilisateur, alimentée par GET /api/alertes/.
class AlertesScreen extends ConsumerWidget {
  const AlertesScreen({super.key});

  Color _couleurNiveau(NiveauGravite niveau) {
    switch (niveau) {
      case NiveauGravite.info:
        return AppColors.bleuIcone;
      case NiveauGravite.avertissement:
        return AppColors.orangeIcone;
      case NiveauGravite.critique:
        return AppColors.erreur;
    }
  }

  String _libelleNiveau(NiveauGravite niveau, BuildContext context) {
    final l10n = context.l10n;
    switch (niveau) {
      case NiveauGravite.info:
        return l10n.niveauInfo;
      case NiveauGravite.avertissement:
        return l10n.niveauAvertissement;
      case NiveauGravite.critique:
        return l10n.niveauCritique;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(alertesProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.alertesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: _corps(context, ref, state, l10n),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, AlertesState state, AppLocalizations l10n) {
    if (state.alertes == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.alertes == null && state.echec != null) {
      return _etatErreur(context, ref, state.echec!, l10n);
    }

    final alertes = state.alertes ?? const [];

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(alertesProvider.notifier).charger(),
      child: alertes.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    l10n.aucuneAlerte,
                    style: AppTextStyles.sousTexteBienvenue,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: alertes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CarteAlerte(
                alerte: alertes[index],
                couleur: _couleurNiveau(alertes[index].niveauGravite),
                libelleNiveau: _libelleNiveau(alertes[index].niveauGravite, context),
              ),
            ),
    );
  }

  Widget _etatErreur(BuildContext context, WidgetRef ref, Failure echec, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.grisMoyen),
            const SizedBox(height: 16),
            Text(
              echec.messageLocalise(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.sousTexteBienvenue,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
              onPressed: () => ref.read(alertesProvider.notifier).charger(),
              child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteAlerte extends StatelessWidget {
  final AlerteEntity alerte;
  final Color couleur;
  final String libelleNiveau;

  const _CarteAlerte({required this.alerte, required this.couleur, required this.libelleNiveau});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormatee = DateFormat.yMMMd(l10n.localeName).add_Hm().format(alerte.dateCreation);

    return CarteStylisee(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: couleur.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        libelleNiveau,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleur),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alerte.estResolue ? l10n.alerteResolue : l10n.alerteNonResolue,
                      style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alerte.message,
                  style: const TextStyle(fontSize: 14, color: AppColors.grisFonce),
                ),
                const SizedBox(height: 6),
                Text(dateFormatee, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
