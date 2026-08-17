import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/classification_qualite.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/files/telechargeur_fichier.dart';
import '../../../../core/local_storage/statut_synchronisation.dart';
import '../../../../core/sync/synchronisation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../../../configuration/domain/entities/configuration_entity.dart';
import '../../../historique/domain/entities/demande_export_entity.dart';
import '../../../historique/presentation/providers/historique_provider.dart';
import '../../../modeles/domain/entities/modele_entity.dart';
import '../../domain/entities/nouvel_echantillon_entity.dart';
import '../../domain/entities/resultat_a_creer_entity.dart';
import '../providers/nouvelle_analyse_provider.dart';
import 'carte_apercu_temps_reel.dart';

/// Étape 4 "Résultats" — 100% alimentée par ce que NouvelleAnalyseNotifier a
/// réellement calculé et enregistré localement (voir _creerResultat) :
/// aucune valeur en dur. Voir domain/services/repartiteur_predictions.dart
/// pour la répartition des prédictions "brutes" du scan sur les modèles
/// actifs réels.
class EtapeResultats extends ConsumerWidget {
  final NouvelleAnalyseState state;
  final NouvelleAnalyseNotifier notifier;

  const EtapeResultats({super.key, required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final echantillon = state.echantillonValide ?? state.brouillon;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        _EnTeteResultat(echantillon: echantillon, resultat: state.resultatCree),
        const SizedBox(height: 16),
        if (state.calculResultatEnCours)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.vertOlive),
                  const SizedBox(height: 12),
                  Text(l10n.calculResultatEnCoursTexte, style: AppTextStyles.sousTexteBienvenue),
                ],
              ),
            ),
          )
        else if (state.resultatCree != null) ...[
          _BlocPredictionsAcidite(
            resultat: state.resultatCree!,
            modeles: state.modelesResultat,
            configuration: state.configurationResultat,
          ),
          const SizedBox(height: 16),
          _BlocAuthenticite(resultat: state.resultatCree!, modeles: state.modelesResultat),
          const SizedBox(height: 16),
        ] else if (state.aucunModeleActifPourResultat) ...[
          _MessageAucunModeleActif(),
          const SizedBox(height: 16),
        ],
        if (state.dernierSpectre != null) ...[
          _BlocSpectreAcquis(spectre: state.dernierSpectre!),
          const SizedBox(height: 16),
        ],
        if (state.resultatId != null) _IndicateurSynchronisation(resultatId: state.resultatId!),
        const SizedBox(height: 20),
        _BoutonsResultats(state: state, notifier: notifier),
      ],
    );
  }
}

class _EnTeteResultat extends StatelessWidget {
  final NouvelEchantillonEntity echantillon;
  final ResultatACreerEntity? resultat;

  const _EnTeteResultat({required this.echantillon, required this.resultat});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMMMMEEEEd(l10n.localeName).add_Hm();

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            echantillon.numero,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 4),
          Text(formatDate.format(echantillon.dateAnalyse), style: AppTextStyles.sousTexteBienvenue),
          if (resultat != null) ...[
            const Divider(height: 24, color: AppColors.grisLigne),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dureeAnalyseLabel, style: const TextStyle(fontSize: 13, color: AppColors.grisMoyen)),
                Text(
                  l10n.dureeMinSec(
                    resultat!.dureeAnalyseSecondes ~/ 60,
                    resultat!.dureeAnalyseSecondes % 60,
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

ModeleEntity? _trouverModele(List<ModeleEntity> modeles, int id) {
  for (final modele in modeles) {
    if (modele.id == id) return modele;
  }
  return null;
}

String _categorieLabel(BuildContext context, {required double acidite, required ConfigurationEntity? configuration}) {
  final l10n = context.l10n;
  if (configuration == null) return '—';
  switch (classifierAcidite(acidite: acidite, configuration: configuration)) {
    case CategorieQualiteHuile.evoo:
      return l10n.categorieEvooLabel;
    case CategorieQualiteHuile.voo:
      return l10n.categorieVooLabel;
    case CategorieQualiteHuile.lampante:
      return l10n.categorieLampanteLabel;
  }
}

class _BlocPredictionsAcidite extends StatelessWidget {
  final ResultatACreerEntity resultat;
  final List<ModeleEntity> modeles;
  final ConfigurationEntity? configuration;

  const _BlocPredictionsAcidite({
    required this.resultat,
    required this.modeles,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDecimal = NumberFormat('#,##0.000', l10n.localeName);
    final lignes = resultat.predictions.where((prediction) {
      final modele = _trouverModele(modeles, prediction.modeleId);
      return modele != null &&
          modele.typeModele == TypeModele.regression &&
          modele.grandeurPredite == GrandeurPredite.acidite &&
          prediction.valeurNumerique != null;
    }).toList();

    if (lignes.isEmpty) return const SizedBox.shrink();

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.blocPredictionsAciditeTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lignes.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: AppColors.grisLigne),
            Builder(builder: (context) {
              final prediction = lignes[i];
              final modele = _trouverModele(modeles, prediction.modeleId)!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${modele.nom} • ${l10n.modeleVersionLabel(modele.version)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                        ),
                        Text(
                          _categorieLabel(context, acidite: prediction.valeurNumerique!, configuration: configuration),
                          style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${formatDecimal.format(prediction.valeurNumerique)} %',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.vertOliveFonce),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _BlocAuthenticite extends StatelessWidget {
  final ResultatACreerEntity resultat;
  final List<ModeleEntity> modeles;

  const _BlocAuthenticite({required this.resultat, required this.modeles});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lignes = resultat.predictions.where((prediction) {
      final modele = _trouverModele(modeles, prediction.modeleId);
      return modele != null &&
          modele.typeModele == TypeModele.classification &&
          prediction.classePredite != null &&
          prediction.classePredite!.isNotEmpty;
    }).toList();

    if (lignes.isEmpty) return const SizedBox.shrink();

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.blocAuthenticiteTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lignes.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: AppColors.grisLigne),
            Builder(builder: (context) {
              final prediction = lignes[i];
              final modele = _trouverModele(modeles, prediction.modeleId)!;
              final estPure = prediction.classePredite == 'pure';
              final couleur = estPure ? AppColors.succes : AppColors.erreur;
              final confiance = prediction.scoreConfiance == null
                  ? null
                  : (prediction.scoreConfiance! * 100).round();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${modele.nom} • ${l10n.modeleVersionLabel(modele.version)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: couleur.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estPure ? l10n.huilePureLabel : l10n.melangeDetecteLabel,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur),
                        ),
                      ),
                      if (confiance != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.scoreConfianceLabel(confiance),
                          style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MessageAucunModeleActif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeFond,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.orangeIcone),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.aucunModeleActifTexte,
              style: const TextStyle(fontSize: 13, color: AppColors.grisFonce),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlocSpectreAcquis extends StatelessWidget {
  final SpectreBrutEntity spectre;

  const _BlocSpectreAcquis({required this.spectre});

  @override
  Widget build(BuildContext context) {
    // Réutilise le même graphique que l'acquisition en temps réel : le
    // spectre final est simplement son dernier état "complet".
    return CarteApercuTempsReel(spectre: spectre, qualite: null);
  }
}

class _IndicateurSynchronisation extends ConsumerWidget {
  final String resultatId;

  const _IndicateurSynchronisation({required this.resultatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statut = ref.watch(resultatStatutSyncProvider(resultatId)).valueOrNull;

    final (texte, couleur, icone) = switch (statut) {
      StatutSynchronisation.synchronise => (l10n.indicateurSyncSynchroniseTexte, AppColors.succes, Icons.cloud_done),
      StatutSynchronisation.erreur => (l10n.indicateurSyncErreurTexte, AppColors.erreur, Icons.cloud_off),
      _ => (l10n.indicateurSyncEnAttenteTexte, AppColors.orangeIcone, Icons.sync),
    };

    return Row(
      children: [
        Icon(icone, size: 16, color: couleur),
        const SizedBox(width: 8),
        Text(texte, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur)),
      ],
    );
  }
}

class _BoutonsResultats extends ConsumerWidget {
  final NouvelleAnalyseState state;
  final NouvelleAnalyseNotifier notifier;

  const _BoutonsResultats({required this.state, required this.notifier});

  Future<void> _exporter(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final historiqueNotifier = ref.read(historiqueProvider.notifier);
    final resultat = await historiqueNotifier.declencherEtTelecharger(DemandeExportEntity(
      contenu: ContenuExport.resultats,
      format: 'XLSX',
      identifiants: [state.resultatId!],
    ));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statut = state.resultatId == null
        ? null
        : ref.watch(resultatStatutSyncProvider(state.resultatId!)).valueOrNull;
    // "Exporter"/"Voir dans l'historique" pointent vers l'API — inutiles
    // (et voués à échouer) tant que ce résultat n'est pas encore synchronisé.
    final actionsDisponibles = state.resultatId != null && statut == StatutSynchronisation.synchronise;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: notifier.demarrerNouvelleAnalyse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vertOlive,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh, color: AppColors.blanc, size: 18),
            label: Text(l10n.nouvelleAnalyseBouton, style: AppTextStyles.boutonPrincipal),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: actionsDisponibles ? () => _exporter(context, ref) : null,
                icon: const Icon(Icons.ios_share, size: 16),
                label: Text(l10n.exporterResultatBouton, style: const TextStyle(fontSize: 13)),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: actionsDisponibles
                    ? () => context.go('/historique/resultat/${state.resultatId}')
                    : null,
                icon: const Icon(Icons.history, size: 16),
                label: Text(l10n.voirDansHistoriqueBouton, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
