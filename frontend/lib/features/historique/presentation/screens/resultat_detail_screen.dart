import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../providers/resultat_detail_provider.dart';

/// Détail d'un résultat d'analyse, alimenté par GET /api/resultats/{id}/.
/// Accessible depuis l'activité récente du dashboard et depuis l'historique.
class ResultatDetailScreen extends ConsumerWidget {
  final String resultatId;

  const ResultatDetailScreen({super.key, required this.resultatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(resultatDetailProvider(resultatId));

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.detailResultatTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, ResultatDetailState state) {
    final l10n = context.l10n;

    if (state.resultat == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.resultat == null && state.echec != null) {
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
                onPressed: () => ref.read(resultatDetailProvider(resultatId).notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    if (state.resultat == null) {
      return const SizedBox.shrink();
    }

    return _DetailContenu(resultat: state.resultat!);
  }
}

class _DetailContenu extends StatelessWidget {
  final ResultatHistoriqueEntity resultat;

  const _DetailContenu({required this.resultat});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDecimal = NumberFormat('#,##0.000', l10n.localeName);
    final formatDate = DateFormat.yMMMMEEEEd(l10n.localeName).add_Hm();
    final couleur = resultat.conforme ? AppColors.succes : AppColors.erreur;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CarteStylisee(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    resultat.numeroEchantillon,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
                  ),
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
              const SizedBox(height: 4),
              Text(
                '${resultat.origineEchantillon} • ${resultat.varieteEchantillon}',
                style: AppTextStyles.sousTexteBienvenue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CarteStylisee(
          child: Column(
            children: [
              _LigneChamp(libelle: l10n.acidite, valeur: '${formatDecimal.format(resultat.acidite)} %'),
              const Divider(height: 20, color: AppColors.grisLigne),
              _LigneChamp(
                libelle: l10n.indicePeroxyde,
                valeur: formatDecimal.format(resultat.indicePeroxyde),
              ),
              const Divider(height: 20, color: AppColors.grisLigne),
              _LigneChamp(
                libelle: l10n.dureeAnalyseLabel,
                valeur: resultat.dureeAnalyseSecondes == null
                    ? '—'
                    : l10n.dureeMinSec(
                        resultat.dureeAnalyseSecondes! ~/ 60,
                        resultat.dureeAnalyseSecondes! % 60,
                      ),
              ),
              const Divider(height: 20, color: AppColors.grisLigne),
              _LigneChamp(libelle: l10n.dateCalculLabel, valeur: formatDate.format(resultat.dateCalcul)),
            ],
          ),
        ),
        if (resultat.commentaire.isNotEmpty) ...[
          const SizedBox(height: 16),
          CarteStylisee(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.commentaireLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisMoyen),
                ),
                const SizedBox(height: 6),
                Text(resultat.commentaire, style: const TextStyle(fontSize: 14, color: AppColors.grisFonce)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LigneChamp extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _LigneChamp({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(libelle, style: const TextStyle(fontSize: 14, color: AppColors.grisMoyen)),
        Text(
          valeur,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
        ),
      ],
    );
  }
}
