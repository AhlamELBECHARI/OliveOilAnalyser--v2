import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../profil/presentation/providers/profil_provider.dart';
import '../../domain/entities/modele_entity.dart';
import '../providers/modeles_provider.dart';
import '../widgets/feuille_ajouter_modele.dart';

/// Liste des modèles d'analyse disponibles, alimentée par GET /api/modeles/.
/// Consultation et import ouverts à tout utilisateur authentifié (voir
/// ModeleViewSet.get_permissions côté backend) ; activation/dépréciation et
/// suppression restent réservées aux administrateurs, ces actions affectant
/// le modèle utilisé par tous — voir profilProvider, déjà chargé par
/// l'écran Profil.
class ModelesScreen extends ConsumerWidget {
  const ModelesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(modelesProvider);
    final estAdmin = ref.watch(profilProvider).profil?.estAdministrateur ?? false;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.navModeles, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.vertOlive,
        onPressed: () => afficherFeuilleAjouterModele(context),
        icon: const Icon(Icons.add, color: AppColors.blanc),
        label: Text(l10n.ajouterModeleBouton, style: AppTextStyles.boutonPrincipal),
      ),
      body: _corps(context, ref, state, estAdmin),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, ModelesState state, bool estAdmin) {
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
              itemBuilder: (context, index) =>
                  _CarteModele(modele: modeles[index], estAdmin: estAdmin),
            ),
    );
  }
}

class _CarteModele extends ConsumerWidget {
  final ModeleEntity modele;
  final bool estAdmin;

  const _CarteModele({required this.modele, required this.estAdmin});

  Future<void> _changerStatut(BuildContext context, WidgetRef ref, String action) async {
    final notifier = ref.read(modelesProvider.notifier);
    switch (action) {
      case 'activer':
        await notifier.modifierStatut(modele.id, estActif: true);
      case 'desactiver':
        await notifier.modifierStatut(modele.id, estActif: false);
      case 'deprecier':
        await notifier.modifierStatut(modele.id, estDeprecie: true);
      case 'retirer_depreciation':
        await notifier.modifierStatut(modele.id, estDeprecie: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              if (estAdmin) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.grisMoyen),
                  onSelected: (action) => _changerStatut(context, ref, action),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: modele.estActif ? 'desactiver' : 'activer',
                      child: Text(modele.estActif ? l10n.desactiverModeleAction : l10n.activerModeleAction),
                    ),
                    PopupMenuItem(
                      value: modele.estDeprecie ? 'retirer_depreciation' : 'deprecier',
                      child: Text(
                        modele.estDeprecie
                            ? l10n.retirerDepreciationModeleAction
                            : l10n.deprecierModeleAction,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                l10n.modeleVersionLabel(modele.version),
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 8),
              _InsigneTypeModele(type: modele.typeModele),
              if (modele.estReference) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: l10n.modeleReferenceLabel,
                  child: const Icon(Icons.star, size: 14, color: AppColors.orangeIcone),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metrique(libelle: l10n.modeleAlgorithmeLabel, valeur: modele.algorithme),
              if (modele.typeModele == TypeModele.regression) ...[
                _Metrique(
                  libelle: l10n.modeleR2Label,
                  valeur: modele.r2 == null ? '—' : formatDecimal.format(modele.r2),
                ),
                _Metrique(
                  libelle: l10n.modeleRmsecvLabel,
                  valeur: modele.rmsecv == null ? '—' : formatDecimal.format(modele.rmsecv),
                ),
              ] else ...[
                _Metrique(
                  libelle: l10n.modeleExactitudeLabel,
                  valeur: modele.exactitude == null ? '—' : formatDecimal.format(modele.exactitude),
                ),
                _Metrique(
                  libelle: l10n.modelePrecisionLabel,
                  valeur: modele.precisionClassification == null
                      ? '—'
                      : formatDecimal.format(modele.precisionClassification),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InsigneTypeModele extends StatelessWidget {
  final TypeModele type;

  const _InsigneTypeModele({required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estRegression = type == TypeModele.regression;
    final couleur = estRegression ? AppColors.vertOliveFonce : AppColors.orangeIcone;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estRegression ? Icons.trending_up : Icons.category_outlined, size: 11, color: couleur),
          const SizedBox(width: 4),
          Text(
            estRegression ? l10n.typeModeleRegressionLabel : l10n.typeModeleClassificationLabel,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: couleur),
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
