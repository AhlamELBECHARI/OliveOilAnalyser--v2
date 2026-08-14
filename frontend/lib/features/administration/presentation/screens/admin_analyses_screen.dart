import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/files/telechargeur_fichier.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../historique/domain/entities/analyse_historique_entity.dart';
import '../../../historique/domain/entities/demande_export_entity.dart';
import '../../../historique/presentation/providers/historique_provider.dart';
import '../../../historique/presentation/widgets/barre_recherche_filtres.dart';
import '../../../historique/presentation/widgets/carte_analyse_historique.dart';
import '../../../historique/presentation/widgets/carte_apercu_historique.dart';
import '../../../historique/presentation/widgets/carte_statistiques_rapides.dart';
import '../../../historique/presentation/widgets/feuille_export.dart';
import '../../../historique/presentation/widgets/feuille_filtres.dart';
import '../widgets/entete_ecran_admin.dart';

/// Onglet "Analyses" de l'espace admin — dédié (ne réutilise plus
/// HistoriqueScreen), enrichi d'une colonne opérateur sur chaque ligne et
/// d'un filtre opérateur pouvant être pré-rempli en arrivant depuis
/// UtilisateurDetailScreen ("Voir ses analyses"). Réutilise le même
/// HistoriqueNotifier que HistoriqueScreen (voir adminAnalysesProvider),
/// juste avec un état initial différent — aucune logique de
/// chargement/export dupliquée.
class AdminAnalysesScreen extends ConsumerWidget {
  final int? operateurInitial;
  final String? operateurNomInitial;

  const AdminAnalysesScreen({super.key, this.operateurInitial, this.operateurNomInitial});

  Future<void> _terminerExport(
    BuildContext context,
    WidgetRef ref,
    Either<Failure, FichierExporte> resultat,
  ) async {
    final l10n = context.l10n;
    if (!context.mounted) return;
    await resultat.fold(
      (failure) async {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context))));
      },
      (fichier) async {
        final enregistre = await TelechargeurFichier.enregistrer(
          nomFichier: fichier.nomFichier,
          octets: fichier.octets,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(enregistre ? l10n.exportTelechargeMessage : l10n.exportAnnuleMessage),
        ));
      },
    );
  }

  Future<void> _ouvrirFeuilleExport(
    BuildContext context,
    WidgetRef ref,
    FiltresHistorique filtres,
    int total,
  ) {
    final provider = adminAnalysesProvider(_filtresInitiaux());
    return afficherFeuilleExport(
      context,
      totalAnalysesFiltrees: total,
      onExporterParFiltres: (demande) async {
        final notifier = ref.read(provider.notifier);
        final resultat = await notifier.declencherEtTelecharger(
          DemandeExportEntity(contenu: demande.contenu, format: demande.format, filtres: filtres),
        );
        await _terminerExport(context, ref, resultat);
      },
      onDemarrerSelectionManuelle: ({required contenu, required format}) {
        ref.read(provider.notifier).activerModeSelection(contenu: contenu, format: format);
      },
    );
  }

  Future<void> _validerSelection(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(adminAnalysesProvider(_filtresInitiaux()).notifier);
    final resultat = await notifier.exporterSelection();
    await _terminerExport(context, ref, resultat);
  }

  FiltresHistorique _filtresInitiaux() => FiltresHistorique(operateur: operateurInitial);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = adminAnalysesProvider(_filtresInitiaux());
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: state.modeSelection
          ? AppBar(
              backgroundColor: AppColors.fond,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.grisFonce),
                onPressed: notifier.desactiverModeSelection,
              ),
              title: Text(
                l10n.selectionCompteurTitre(state.idsSelectionnes.length),
                style: AppTextStyles.bienvenue.copyWith(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: notifier.toutSelectionner,
                  child: Text(l10n.toutSelectionnerBouton),
                ),
              ],
            )
          : AppBar(
              backgroundColor: AppColors.fond,
              elevation: 0,
              title: EnTeteEcranAdmin(
                icone: Icons.description_outlined,
                couleur: AppColors.orangeIcone,
                fond: AppColors.orangeFond,
                titre: l10n.navAnalyses,
                sousTitre: l10n.analysesSousTitreAdmin,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.ios_share, color: AppColors.grisFonce),
                  tooltip: l10n.exporterBouton,
                  onPressed: state.exportEnCours
                      ? null
                      : () => _ouvrirFeuilleExport(context, ref, state.filtres, state.totalAnalyses),
                ),
              ],
            ),
      floatingActionButton: state.modeSelection
          ? FloatingActionButton.extended(
              backgroundColor:
                  state.idsSelectionnes.isEmpty ? AppColors.grisMoyen : AppColors.vertOlive,
              onPressed: (state.idsSelectionnes.isEmpty || state.exportEnCours)
                  ? null
                  : () => _validerSelection(context, ref),
              icon: state.exportEnCours
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Icon(Icons.file_download_outlined, color: AppColors.blanc),
              label: Text(l10n.validerExportBouton, style: AppTextStyles.boutonPrincipal),
            )
          : null,
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
          if (state.filtres.operateur != null) ...[
            _ChipOperateur(
              nom: operateurNomInitial ?? '#${state.filtres.operateur}',
              onEffacer: () => notifier.appliquerFiltres(FiltresHistorique(
                recherche: state.filtres.recherche,
                qualite: state.filtres.qualite,
                variete: state.filtres.variete,
                region: state.filtres.region,
                dateDebut: state.filtres.dateDebut,
                dateFin: state.filtres.dateFin,
              )),
            ),
            const SizedBox(height: 12),
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
                  afficherAuteur: true,
                  modeSelection: state.modeSelection,
                  selectionne: state.idsSelectionnes.contains(analyse.id),
                  onTap: state.modeSelection
                      ? () => notifier.basculerSelection(analyse.id)
                      : () async {
                          final supprime = await context.push<bool>(
                            '/admin/analyses/resultat/${analyse.id}',
                          );
                          if (supprime == true) notifier.charger();
                        },
                ),
                const SizedBox(height: 12),
              ],
            ],
            if (state.aPageSuivante && !state.modeSelection)
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

class _ChipOperateur extends StatelessWidget {
  final String nom;
  final VoidCallback onEffacer;

  const _ChipOperateur({required this.nom, required this.onEffacer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.evooFond,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.vertOlive),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 14, color: AppColors.vertOliveFonce),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onEffacer,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.close, size: 14, color: AppColors.vertOliveFonce),
          ),
        ],
      ),
    );
  }
}
