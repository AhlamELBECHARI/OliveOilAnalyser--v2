import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/files/telechargeur_fichier.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../historique/domain/entities/demande_export_entity.dart';
import '../../../historique/domain/usecases/declencher_export_usecase.dart';
import '../../../historique/domain/usecases/telecharger_rapport_usecase.dart';
import '../../domain/entities/gestion_donnees_entity.dart';
import '../providers/gestion_donnees_admin_provider.dart';

String _formaterOctets(int octets) {
  const unites = ['o', 'Ko', 'Mo', 'Go', 'To'];
  var valeur = octets.toDouble();
  var indice = 0;
  while (valeur >= 1024 && indice < unites.length - 1) {
    valeur /= 1024;
    indice++;
  }
  return '${valeur.toStringAsFixed(valeur < 10 && indice > 0 ? 1 : 0)} ${unites[indice]}';
}

/// Gestion des données admin (voir cahier des charges espace admin) : export
/// global (toutes les analyses, pas seulement celles de l'admin — voir
/// analyses.services côté backend, déjà non filtré par auteur pour un
/// admin), purge avec aperçu obligatoire avant confirmation, statistiques
/// d'occupation par table.
class GestionDonneesAdminScreen extends ConsumerStatefulWidget {
  const GestionDonneesAdminScreen({super.key});

  @override
  ConsumerState<GestionDonneesAdminScreen> createState() => _GestionDonneesAdminScreenState();
}

class _GestionDonneesAdminScreenState extends ConsumerState<GestionDonneesAdminScreen> {
  bool _exportEnCours = false;

  Future<void> _exporterGlobal(String format) async {
    setState(() => _exportEnCours = true);
    final resultatExport = await sl<DeclencherExportUseCase>()(
      const DemandeExportEntity(contenu: ContenuExport.resultats, format: 'XLSX'),
    );
    if (!mounted) return;
    final l10n = context.l10n;

    await resultatExport.fold(
      (failure) async {
        setState(() => _exportEnCours = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context))));
      },
      (rapport) async {
        final resultatFichier = await sl<TelechargerRapportUseCase>()(rapport.id);
        if (!mounted) return;
        setState(() => _exportEnCours = false);
        await resultatFichier.fold(
          (failure) async => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context)))),
          (octets) async {
            final nomFichier = rapport.nomFichier ?? 'export.xlsx';
            final enregistre =
                await TelechargeurFichier.enregistrer(nomFichier: nomFichier, octets: octets);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(enregistre ? l10n.exportTelechargeMessage : l10n.exportAnnuleMessage),
            ));
          },
        );
      },
    );
  }

  Future<void> _choisirDateEtPrevisualiser() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(maintenant.year - 1),
      firstDate: DateTime(2020),
      lastDate: maintenant,
    );
    if (date == null || !mounted) return;
    ref.read(gestionDonneesAdminProvider.notifier).previsualiserPurge(date);
  }

  Future<void> _confirmerPurge(PurgeApercuEntity apercu) async {
    final l10n = context.l10n;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.purgeTitre),
        content: Text(
          '${l10n.purgeApercuTitre}\n'
          '${apercu.echantillonsASupprimer} · ${apercu.spectresASupprimer} · '
          '${apercu.resultatsASupprimer}\n\n'
          '${l10n.purgeIrreversibleAvertissement}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.annulerBouton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirmerPurgeBouton, style: const TextStyle(color: AppColors.erreur)),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref.read(gestionDonneesAdminProvider.notifier).confirmerPurge();
      if (!mounted) return;
      final l10nLocal = context.l10n;
      final state = ref.read(gestionDonneesAdminProvider);
      if (state.purgeReussie) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10nLocal.purgeReussieMessage)));
      } else if (state.echecPurge != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.echecPurge!.messageLocalise(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(gestionDonneesAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.gestionDonneesAdminTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _CarteStatistiques(statistiques: state.statistiques, enChargement: state.enChargement),
          const SizedBox(height: 16),
          CarteStylisee(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exportGlobalBouton,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exportEnCours ? null : () => _exporterGlobal('XLSX'),
                    icon: _exportEnCours
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                          )
                        : const Icon(Icons.ios_share, size: 18),
                    label: Text(l10n.exportGlobalBouton),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CarteStylisee(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.purgeTitre,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
                const SizedBox(height: 6),
                Text(l10n.purgeDescriptionTexte, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.erreur,
                      side: const BorderSide(color: AppColors.erreur),
                    ),
                    onPressed: state.apercuEnCours ? null : _choisirDateEtPrevisualiser,
                    icon: state.apercuEnCours
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.erreur),
                          )
                        : const Icon(Icons.event_outlined, size: 18),
                    label: Text(l10n.choisirDateLimitePurge),
                  ),
                ),
                if (state.apercu != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.grisLigne),
                  const SizedBox(height: 8),
                  Text(l10n.purgeApercuTitre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${state.apercu!.echantillonsASupprimer} échantillons · '
                    '${state.apercu!.spectresASupprimer} spectres · '
                    '${state.apercu!.resultatsASupprimer} résultats',
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.erreur),
                      onPressed: state.purgeEnCours ? null : () => _confirmerPurge(state.apercu!),
                      child: state.purgeEnCours
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                            )
                          : Text(l10n.confirmerPurgeBouton, style: AppTextStyles.boutonPrincipal),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteStatistiques extends StatelessWidget {
  final StatistiquesOccupationEntity? statistiques;
  final bool enChargement;

  const _CarteStatistiques({required this.statistiques, required this.enChargement});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = statistiques;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistiquesOccupationTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 8),
          if (stats == null)
            const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
          else ...[
            _ligne(l10n.tailleBaseLabel, _formaterOctets(stats.tailleBaseOctets)),
            _ligne('Échantillons', NumberFormat.decimalPattern(l10n.localeName).format(stats.echantillons)),
            _ligne('Spectres', NumberFormat.decimalPattern(l10n.localeName).format(stats.spectres)),
            _ligne('Résultats', NumberFormat.decimalPattern(l10n.localeName).format(stats.resultats)),
            _ligne('Modèles', NumberFormat.decimalPattern(l10n.localeName).format(stats.modeles)),
            _ligne(l10n.navUtilisateurs, NumberFormat.decimalPattern(l10n.localeName).format(stats.utilisateurs)),
          ],
        ],
      ),
    );
  }

  Widget _ligne(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: const TextStyle(fontSize: 13, color: AppColors.grisMoyen)),
          Text(valeur, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce)),
        ],
      ),
    );
  }
}
