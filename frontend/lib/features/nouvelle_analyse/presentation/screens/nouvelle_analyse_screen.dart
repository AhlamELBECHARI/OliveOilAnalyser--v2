import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/sync/synchronisation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/nouvelle_analyse_provider.dart';
import '../widgets/carte_apercu_temps_reel.dart';
import '../widgets/carte_connexion_instrument.dart';
import '../widgets/carte_informations_echantillon.dart';
import '../widgets/carte_parametres_acquisition_reservee.dart';
import '../widgets/en_tete_nouvelle_analyse.dart';
import '../widgets/stepper_analyse.dart';

/// Écran "Nouvelle Analyse" (design/3-analyse.png), 100% adossé au backend
/// et au module Bluetooth réel (voir features/analyseur) : aucune donnée
/// fictive. Diffère volontairement de la maquette sur la carte
/// "Informations Échantillon", qui s'ouvre en formulaire vide plutôt qu'en
/// consultation pré-remplie — voir Partie A du cahier des charges.
class NouvelleAnalyseScreen extends ConsumerWidget {
  const NouvelleAnalyseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(nouvelleAnalyseProvider);
    final notifier = ref.read(nouvelleAnalyseProvider.notifier);
    final elementsEnAttente = ref.watch(elementsEnAttenteSyncProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  EnTeteNouvelleAnalyse(
                    etatConnexion: state.etatConnexion,
                    onTapScan: notifier.reessayerConnexion,
                  ),
                  if (elementsEnAttente > 0) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.orangeFond,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sync, size: 14, color: AppColors.orangeIcone),
                            const SizedBox(width: 6),
                            Text(
                              l10n.enAttenteSynchronisation(elementsEnAttente),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.orangeIcone),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  StepperAnalyse(etapeCourante: state.etapeCourante),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                children: [
                  CarteInformationsEchantillon(
                    mode: state.modeCarteEchantillon,
                    brouillon: state.brouillon,
                    echantillonValide: state.echantillonValide,
                    enregistrementEnCours: state.enregistrementEnCours,
                    positionEnCoursDeChargement: state.positionEnCoursDeChargement,
                    echecPosition: state.echecPosition,
                    onChangerNumero: notifier.mettreAJourNumero,
                    onChangerProducteur: notifier.mettreAJourProducteur,
                    onChangerVariete: notifier.mettreAJourVariete,
                    onChangerRegion: notifier.mettreAJourRegion,
                    onChangerDateRecolte: notifier.mettreAJourDateRecolte,
                    onPositionActuelle: notifier.definirPositionActuelle,
                    onValider: notifier.validerEchantillon,
                    onModifier: notifier.modifierEchantillon,
                  ),
                  const SizedBox(height: 16),
                  CarteConnexionInstrument(
                    etatConnexion: state.etatConnexion,
                    infoAppareil: state.infoAppareil,
                    onReessayer: notifier.reessayerConnexion,
                  ),
                  const SizedBox(height: 16),
                  const CarteParametresAcquisitionReservee(),
                  if (state.acquisitionEnCours || state.dernierSpectre != null) ...[
                    const SizedBox(height: 16),
                    CarteApercuTempsReel(spectre: state.dernierSpectre, qualite: state.qualiteSignal),
                  ],
                  if (state.acquisitionTerminee) ...[
                    const SizedBox(height: 16),
                    _CarteAnalyseTerminee(onNouvelleAnalyse: () => Navigator.of(context).pop()),
                  ],
                  const SizedBox(height: 20),
                  _BoutonsAction(state: state, notifier: notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonsAction extends StatelessWidget {
  final NouvelleAnalyseState state;
  final NouvelleAnalyseNotifier notifier;

  const _BoutonsAction({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: state.peutDemarrerAnalyse ? notifier.demarrerAnalyse : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vertOlive,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: state.acquisitionEnCours
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                  )
                : const Icon(Icons.monitor_heart_outlined, color: AppColors.blanc, size: 18),
            label: Text(l10n.demarrerAnalyseBouton, style: AppTextStyles.boutonPrincipal),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (state.acquisitionEnCours) {
                notifier.annulerAnalyse();
              } else {
                Navigator.of(context).pop();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.erreur,
              side: const BorderSide(color: AppColors.erreur),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.annulerBouton, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _CarteAnalyseTerminee extends StatelessWidget {
  final VoidCallback onNouvelleAnalyse;

  const _CarteAnalyseTerminee({required this.onNouvelleAnalyse});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.evooFond,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.vertOlive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.succes),
              const SizedBox(width: 8),
              Text(
                l10n.analyseTermineeTitre,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.analyseTermineeTexte, style: AppTextStyles.sousTexteBienvenue),
        ],
      ),
    );
  }
}
