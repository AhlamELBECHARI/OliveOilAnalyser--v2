import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/modele_entity.dart';
import '../providers/modeles_provider.dart';

/// Liste des modèles d'analyse disponibles, alimentée par GET /api/modeles/.
class ModelesScreen extends ConsumerWidget {
  const ModelesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(modelesProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.navModeles, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, ModelesState state) {
    final l10n = context.l10n;

    if (state.modeles == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.modeles == null && state.echec != null) {
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
                onPressed: () => ref.read(modelesProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final modeles = state.modeles ?? const [];

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(modelesProvider.notifier).charger(),
      child: modeles.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    l10n.aucunModele,
                    style: AppTextStyles.sousTexteBienvenue,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: modeles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CarteModele(modele: modeles[index]),
            ),
    );
  }
}

class _CarteModele extends StatelessWidget {
  final ModeleEntity modele;

  const _CarteModele({required this.modele});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDecimal = NumberFormat('#,##0.000', l10n.localeName);
    final couleur = modele.estDeprecie
        ? AppColors.grisMoyen
        : (modele.estActif ? AppColors.succes : AppColors.grisMoyen);
    final libelleStatut = modele.estDeprecie ? l10n.modeleDeprecie : l10n.modeleActif;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  modele.nom,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  libelleStatut,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.modeleVersionLabel(modele.version),
            style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metrique(libelle: l10n.modeleAlgorithmeLabel, valeur: modele.algorithme),
              _Metrique(libelle: l10n.modeleR2Label, valeur: formatDecimal.format(modele.r2)),
              _Metrique(libelle: l10n.modeleRmsecvLabel, valeur: formatDecimal.format(modele.rmsecv)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrique extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _Metrique({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(libelle, style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen)),
          const SizedBox(height: 2),
          Text(
            valeur,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
        ],
      ),
    );
  }
}
