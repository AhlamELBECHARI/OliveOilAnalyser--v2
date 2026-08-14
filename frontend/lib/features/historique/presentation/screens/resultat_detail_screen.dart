import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/telechargeur_fichier.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../../../analyseur/domain/services/calculateur_qualite_signal.dart';
import '../../../nouvelle_analyse/presentation/widgets/carte_apercu_temps_reel.dart';
import '../../domain/entities/demande_export_entity.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/entities/spectre_historique_entity.dart';
import '../providers/historique_provider.dart';
import '../providers/resultat_detail_provider.dart';

/// Détail d'un résultat d'analyse, alimenté par GET /api/resultats/{id}/
/// (onglet Résultats) et GET /api/spectres/?echantillon= (onglet Spectre) —
/// deux natures de données volontairement séparées (voir cahier des
/// charges), chacune avec son propre export. Accessible depuis l'activité
/// récente du dashboard, l'historique, et l'étape Résultats de Nouvelle
/// Analyse une fois le résultat synchronisé.
class ResultatDetailScreen extends ConsumerWidget {
  final String resultatId;

  const ResultatDetailScreen({super.key, required this.resultatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(resultatDetailProvider(resultatId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.fond,
        appBar: AppBar(
          backgroundColor: AppColors.fond,
          elevation: 0,
          title: Text(l10n.detailResultatTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
          bottom: TabBar(
            labelColor: AppColors.vertOliveFonce,
            unselectedLabelColor: AppColors.grisMoyen,
            indicatorColor: AppColors.vertOlive,
            tabs: [
              Tab(text: l10n.ongletResultatsLabel),
              Tab(text: l10n.ongletSpectreLabel),
            ],
          ),
        ),
        body: _corps(context, ref, state),
      ),
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

    return TabBarView(
      children: [
        _OngletResultats(resultatId: resultatId, resultat: state.resultat!),
        _OngletSpectre(resultatId: resultatId, state: state),
      ],
    );
  }
}

Future<void> _exporter(
  BuildContext context,
  WidgetRef ref, {
  required String resultatId,
  required ContenuExport contenu,
}) async {
  final l10n = context.l10n;
  final notifier = ref.read(historiqueProvider.notifier);
  final resultat = await notifier.declencherEtTelecharger(DemandeExportEntity(
    contenu: contenu,
    format: 'XLSX',
    identifiants: [resultatId],
  ));
  if (!context.mounted) return;
  await resultat.fold(
    (failure) async {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context))));
    },
    (fichier) async {
      final enregistre =
          await TelechargeurFichier.enregistrer(nomFichier: fichier.nomFichier, octets: fichier.octets);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(enregistre ? l10n.exportTelechargeMessage : l10n.exportAnnuleMessage),
      ));
    },
  );
}

class _OngletResultats extends ConsumerWidget {
  final String resultatId;
  final ResultatHistoriqueEntity resultat;

  const _OngletResultats({required this.resultatId, required this.resultat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatDecimal = NumberFormat('#,##0.000', l10n.localeName);
    final formatDate = DateFormat.yMMMMEEEEd(l10n.localeName).add_Hm();
    final couleur = resultat.conforme ? AppColors.succes : AppColors.erreur;

    final predictionsRegression =
        resultat.predictions.where((p) => p.typeModele == 'regression').toList();
    final predictionsClassification =
        resultat.predictions.where((p) => p.typeModele == 'classification').toList();

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
                '${resultat.origineEchantillon} • ${resultat.varieteEchantillon} • '
                '${l10n.replicatLabel(resultat.numeroReplicat)}',
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
        if (predictionsRegression.isNotEmpty) ...[
          const SizedBox(height: 16),
          _CartePredictions(titre: l10n.blocPredictionsAciditeTitre, predictions: predictionsRegression),
        ],
        if (predictionsClassification.isNotEmpty) ...[
          const SizedBox(height: 16),
          _CartePredictions(titre: l10n.blocAuthenticiteTitre, predictions: predictionsClassification),
        ],
        if (resultat.aDesValeursReference) ...[
          const SizedBox(height: 16),
          _CarteComparaisonLabo(resultat: resultat, formatDecimal: formatDecimal),
        ],
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
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => _exporter(context, ref, resultatId: resultatId, contenu: ContenuExport.resultats),
          icon: const Icon(Icons.ios_share, size: 16),
          label: Text(l10n.exporterResultatBouton),
        ),
      ],
    );
  }
}

class _CartePredictions extends StatelessWidget {
  final String titre;
  final List<PredictionHistoriqueEntity> predictions;

  const _CartePredictions({required this.titre, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDecimal = NumberFormat('#,##0.000', l10n.localeName);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
          const SizedBox(height: 12),
          for (var i = 0; i < predictions.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: AppColors.grisLigne),
            _LignePrediction(prediction: predictions[i], formatDecimal: formatDecimal),
          ],
        ],
      ),
    );
  }
}

class _LignePrediction extends StatelessWidget {
  final PredictionHistoriqueEntity prediction;
  final NumberFormat formatDecimal;

  const _LignePrediction({required this.prediction, required this.formatDecimal});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nomModele = '${prediction.modeleNom} • ${l10n.modeleVersionLabel(prediction.modeleVersion)}';

    if (prediction.typeModele == 'regression') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(nomModele, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
          ),
          Text(
            prediction.valeurNumerique == null ? '—' : formatDecimal.format(prediction.valeurNumerique),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.vertOliveFonce),
          ),
        ],
      );
    }

    final estPure = prediction.classePredite == 'pure';
    final couleur = estPure ? AppColors.succes : AppColors.erreur;
    final confiance =
        prediction.scoreConfiance == null ? null : (prediction.scoreConfiance! * 100).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(nomModele, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
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
              Text(l10n.scoreConfianceLabel(confiance), style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen)),
            ],
          ],
        ),
      ],
    );
  }
}

class _CarteComparaisonLabo extends StatelessWidget {
  final ResultatHistoriqueEntity resultat;
  final NumberFormat formatDecimal;

  const _CarteComparaisonLabo({required this.resultat, required this.formatDecimal});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.blocComparaisonLaboTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          if (resultat.aciditeReference != null) ...[
            _LigneComparaison(
              libelle: l10n.acidite,
              predite: resultat.acidite,
              reference: resultat.aciditeReference!,
              formatDecimal: formatDecimal,
            ),
            const Divider(height: 20, color: AppColors.grisLigne),
          ],
          if (resultat.indicePeroxydeReference != null)
            _LigneComparaison(
              libelle: l10n.indicePeroxyde,
              predite: resultat.indicePeroxyde,
              reference: resultat.indicePeroxydeReference!,
              formatDecimal: formatDecimal,
            ),
          if (resultat.authenticiteReference != null) ...[
            const Divider(height: 20, color: AppColors.grisLigne),
            _LigneChamp(
              libelle: l10n.authenticiteReferenceLabel,
              valeur: resultat.authenticiteReference == 'pure' ? l10n.huilePureLabel : l10n.melangeDetecteLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _LigneComparaison extends StatelessWidget {
  final String libelle;
  final double predite;
  final double reference;
  final NumberFormat formatDecimal;

  const _LigneComparaison({
    required this.libelle,
    required this.predite,
    required this.reference,
    required this.formatDecimal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ecart = predite - reference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Metrique(libelle: l10n.valeurPrediteLabel, valeur: formatDecimal.format(predite)),
            _Metrique(libelle: l10n.valeurReferenceLabel, valeur: formatDecimal.format(reference)),
            _Metrique(
              libelle: l10n.ecartLabel,
              valeur: '${ecart >= 0 ? '+' : ''}${formatDecimal.format(ecart)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _Metrique extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _Metrique({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen)),
        const SizedBox(height: 2),
        Text(valeur, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
      ],
    );
  }
}

class _OngletSpectre extends ConsumerWidget {
  final String resultatId;
  final ResultatDetailState state;

  const _OngletSpectre({required this.resultatId, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (state.spectreEnChargement && state.spectre == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.echecSpectre != null && state.spectre == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.grisMoyen),
              const SizedBox(height: 16),
              Text(
                state.echecSpectre!.messageLocalise(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                onPressed: () => ref
                    .read(resultatDetailProvider(resultatId).notifier)
                    .chargerSpectre(state.resultat!.echantillonId),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final spectre = state.spectre;
    if (spectre == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.aucuneDonneeSpectreTexte, textAlign: TextAlign.center, style: AppTextStyles.sousTexteBienvenue),
        ),
      );
    }

    final spectreBrut = _versSpectreBrut(spectre);
    final qualite = calculerQualiteSignal(spectreBrut);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CarteApercuTempsReel(spectre: spectreBrut, qualite: qualite),
        const SizedBox(height: 16),
        CarteStylisee(
          child: _LigneChamp(libelle: l10n.nombrePointsLabel, valeur: '${spectre.nombreSeries}'),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => _exporter(context, ref, resultatId: resultatId, contenu: ContenuExport.spectres),
          icon: const Icon(Icons.ios_share, size: 16),
          label: Text(l10n.exporterSpectreBouton),
        ),
      ],
    );
  }

  SpectreBrutEntity _versSpectreBrut(SpectreHistoriqueEntity spectre) {
    return SpectreBrutEntity(
      points: [
        for (var i = 0; i < spectre.valeursX.length; i++)
          PointSpectreEntity(longueurOndeNm: spectre.valeursX[i], absorbance: spectre.valeursY[i]),
      ],
      dateAcquisition: spectre.dateAcquisition,
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
