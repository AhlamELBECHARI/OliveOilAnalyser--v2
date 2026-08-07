import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../providers/historique_provider.dart';
import '../widgets/barre_recherche_filtres.dart';
import '../widgets/carte_analyse_historique.dart';
import '../widgets/carte_apercu_historique.dart';
import '../widgets/carte_statistiques_rapides.dart';
import '../widgets/feuille_filtres.dart';

/// Écran Historique (design/4-historiques.png) : 100% alimenté par
/// GET /api/analyses/historique/ et /api/analyses/statistiques-rapides/,
/// recherche/filtres/tri/pagination entièrement côté serveur.
class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  Future<void> _exporter(BuildContext context, WidgetRef ref, String format) async {
    final l10n = context.l10n;
    final resultat = await ref.read(historiqueProvider.notifier).exporter(format);
    if (!context.mounted) return;
    resultat.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context)))),
      (_) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.exportLanceMessage))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(historiqueProvider);
    final notifier = ref.read(historiqueProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.historiquesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
            Text(l10n.historiquesSousTitre, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share, color: AppColors.grisFonce),
            tooltip: l10n.exporterBouton,
            onSelected: (format) => _exporter(context, ref, format),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'PDF', child: Text('PDF')),
              PopupMenuItem(value: 'CSV', child: Text('CSV')),
              PopupMenuItem(value: 'XLSX', child: Text('XLSX')),
            ],
          ),
        ],
      ),
      body: _corps(context, ref, state, notifier),
    );
  }

  Widget _corps(
    BuildContext context,
    WidgetRef ref,
    HistoriqueState state,
    HistoriqueNotifier notifier,
  ) {
    final l10n = context.l10n;

    if (state.analyses == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.analyses == null && state.echec != null) {
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
                onPressed: notifier.charger,
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final analyses = state.analyses ?? const [];
    final groupes = _grouperParMois(analyses, l10n.localeName);

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: notifier.charger,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (state.statistiques != null) ...[
            CarteApercuHistorique(apercu: state.statistiques!.apercu),
            const SizedBox(height: 16),
          ],
          BarreRechercheFiltres(
            filtres: state.filtres,
            onChangerFiltres: notifier.appliquerFiltres,
            onOuvrirPlusDeFiltres: () => afficherFeuilleFiltres(
              context,
              filtresActuels: state.filtres,
              onAppliquer: notifier.appliquerFiltres,
            ),
          ),
          const SizedBox(height: 16),
          if (analyses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(l10n.aucunResultat, style: AppTextStyles.sousTexteBienvenue),
              ),
            )
          else ...[
            for (final groupe in groupes) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  groupe.libelleMois,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisMoyen),
                ),
              ),
              for (final analyse in groupe.analyses) ...[
                CarteAnalyseHistorique(
                  analyse: analyse,
                  onTap: () => context.push('/historique/resultat/${analyse.id}'),
                ),
                const SizedBox(height: 12),
              ],
            ],
            if (state.aPageSuivante)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: state.chargementPageSuivante ? null : notifier.chargerPageSuivante,
                    child: state.chargementPageSuivante
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                          )
                        : Text(l10n.chargerPlusAnalyses),
                  ),
                ),
              ),
          ],
          if (state.statistiques != null) ...[
            const SizedBox(height: 20),
            CarteStatistiquesRapides(
              tendanceAciditeMoyenne: state.statistiques!.tendanceAciditeMoyenne,
              meilleureQualite: state.statistiques!.meilleureQualite,
              plusForteAcidite: state.statistiques!.plusForteAcidite,
              analysesParJour: state.statistiques!.analysesParJour,
            ),
          ],
        ],
      ),
    );
  }

  List<_GroupeMois> _grouperParMois(List<AnalyseHistoriqueEntity> analyses, String locale) {
    final format = DateFormat.yMMMM(locale);
    final groupes = <_GroupeMois>[];
    for (final analyse in analyses) {
      final libelle = format.format(analyse.dateCalcul);
      if (groupes.isNotEmpty && groupes.last.libelleMois == libelle) {
        groupes.last.analyses.add(analyse);
      } else {
        groupes.add(_GroupeMois(libelleMois: libelle, analyses: [analyse]));
      }
    }
    return groupes;
  }
}

class _GroupeMois {
  final String libelleMois;
  final List<AnalyseHistoriqueEntity> analyses;

  _GroupeMois({required this.libelleMois, required this.analyses});
}
