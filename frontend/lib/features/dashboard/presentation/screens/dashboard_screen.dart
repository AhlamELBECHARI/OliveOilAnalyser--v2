import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/demo/demo_mode_provider.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/etat_analyseur_entity.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/carte_activite_recente.dart';
import '../widgets/carte_analyses_recentes.dart';
import '../widgets/carte_etat_laboratoire.dart';
import '../widgets/carte_qualite_huiles.dart';
import '../widgets/carte_statistique.dart';
import '../widgets/dashboard_header.dart';

/// Écran d'accueil / tableau de bord (design/2-dashboard.png). Un onglet de
/// la coquille de navigation (voir core/navigation/app_router.dart) : ne
/// déclare plus sa propre BottomNavigationBar, celle-ci vit une seule fois
/// dans CoquilleNavigation.
///
/// S'alimente exclusivement de GET /api/dashboard/statistiques/ via
/// [dashboardProvider], avec tirer-pour-actualiser — y compris en Mode
/// démo, qui n'affiche qu'une bannière cosmétique (voir
/// core/demo/demo_mode_provider.dart) : les données restent toujours
/// celles renvoyées par l'API pour le compte connecté.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(child: _ContenuReel()),
    );
  }
}

class _ContenuReel extends ConsumerWidget {
  const _ContenuReel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(dashboardProvider);
    final estModeDemo = ref.watch(demoModeProvider);

    if (state.statistiques == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.statistiques == null && state.echec != null) {
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
                onPressed: () => ref.read(dashboardProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    if (state.statistiques == null) {
      return const SizedBox.shrink();
    }

    return _DashboardContenu(
      statistiques: state.statistiques!,
      etatAnalyseur: state.etatAnalyseur,
      alertesNonLues: state.alertesNonLues,
      onRafraichir: () => ref.read(dashboardProvider.notifier).charger(),
      banniereModeDemo: estModeDemo,
    );
  }
}

class _DashboardContenu extends StatelessWidget {
  final StatistiquesDashboardEntity statistiques;
  final EtatAnalyseurEntity? etatAnalyseur;
  final int alertesNonLues;
  final Future<void> Function() onRafraichir;
  final bool banniereModeDemo;

  const _DashboardContenu({
    required this.statistiques,
    required this.etatAnalyseur,
    required this.alertesNonLues,
    required this.onRafraichir,
    required this.banniereModeDemo,
  });

  String? _texteVariationMois(double? variation, AppLocalizations l10n, NumberFormat formatVariation) {
    if (variation == null) return null;
    return l10n.variationVsMoisDernier(formatVariation.format(variation.abs()));
  }

  String? _texteVariationHier(double? variation, AppLocalizations l10n, NumberFormat formatVariation) {
    if (variation == null) return null;
    return l10n.variationVsHier(formatVariation.format(variation.abs()));
  }

  String _formaterDuree(double? minutes, AppLocalizations l10n) {
    if (minutes == null) return '—';
    final totalSecondes = (minutes * 60).round();
    return l10n.dureeMinSec(totalSecondes ~/ 60, totalSecondes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatNombre = NumberFormat.decimalPattern(l10n.localeName);
    final formatVariation = NumberFormat('#,##0.0', l10n.localeName);
    final formatVariationEntiere = NumberFormat('#,##0', l10n.localeName);

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: onRafraichir,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          if (banniereModeDemo) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.vertOlive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.vertOlive),
              ),
              child: Text(l10n.modeDemoBanniere, style: AppTextStyles.sousTexteBienvenue),
            ),
            const SizedBox(height: 16),
          ],
          DashboardHeader(
            nomUtilisateur: statistiques.nomUtilisateur,
            alertesNonLues: alertesNonLues,
            onTapNotifications: () => context.push('/accueil/alertes'),
            onTapScan: () => context.go('/analyse'),
          ),
          const SizedBox(height: 20),
          if (etatAnalyseur != null) CarteEtatLaboratoire(etat: etatAnalyseur!),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CarteStatistique(
                  icone: Icons.science_outlined,
                  couleurIcone: AppColors.vertOliveFonce,
                  fondIcone: AppColors.evooFond,
                  libelle: l10n.analysesCeMois,
                  valeur: formatNombre.format(statistiques.analysesCeMois.valeur),
                  variationTexte: _texteVariationMois(
                    statistiques.analysesCeMois.variationPourcentage,
                    l10n,
                    formatVariation,
                  ),
                  variationPositive: (statistiques.analysesCeMois.variationPourcentage ?? 0) >= 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CarteStatistique(
                  icone: Icons.water_drop_outlined,
                  couleurIcone: AppColors.orangeIcone,
                  fondIcone: AppColors.orangeFond,
                  libelle: l10n.echantillonsTotaux,
                  valeur: formatNombre.format(statistiques.echantillonsTotaux.valeur),
                  variationTexte: l10n.ajoutsCeMois(
                    formatNombre.format(statistiques.echantillonsTotaux.ajoutsCeMois),
                  ),
                  variationPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CarteStatistique(
                  icone: Icons.calendar_today_outlined,
                  couleurIcone: AppColors.bleuIcone,
                  fondIcone: AppColors.bleuFond,
                  libelle: l10n.analysesAujourdHui,
                  valeur: formatNombre.format(statistiques.analysesAujourdHui.valeur),
                  variationTexte: _texteVariationHier(
                    statistiques.analysesAujourdHui.variationPourcentage,
                    l10n,
                    formatVariationEntiere,
                  ),
                  variationPositive: (statistiques.analysesAujourdHui.variationPourcentage ?? 0) >= 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CarteStatistique(
                  icone: Icons.access_time,
                  couleurIcone: AppColors.orangeIcone,
                  fondIcone: AppColors.orangeFond,
                  libelle: l10n.tempsMoyenParAnalyse,
                  valeur: _formaterDuree(statistiques.tempsMoyenParAnalyse.valeur, l10n),
                  variationTexte: _texteVariationMois(
                    statistiques.tempsMoyenParAnalyse.variationPourcentage,
                    l10n,
                    formatVariationEntiere,
                  ),
                  variationPositive: (statistiques.tempsMoyenParAnalyse.variationPourcentage ?? 0) < 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CarteAnalysesRecentes(serie: statistiques.serie7Jours),
          const SizedBox(height: 16),
          CarteQualiteHuiles(
            repartition: statistiques.repartitionQualite,
            onVoirDetail: () => context.push(
              '/accueil/repartition-qualite',
              extra: statistiques.repartitionQualite,
            ),
          ),
          const SizedBox(height: 16),
          CarteActiviteRecente(
            analyses: statistiques.analysesRecentes,
            onVoirHistorique: () => context.go('/historique'),
            onTapAnalyse: (analyse) => context.push('/accueil/resultat/${analyse.resultatId}'),
          ),
        ],
      ),
    );
  }
}
