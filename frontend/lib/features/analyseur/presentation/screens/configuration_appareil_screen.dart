import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/appareil_appaire_entity.dart';
import '../../domain/entities/appareil_decouvert_entity.dart';
import '../../domain/entities/etat_connexion_analyseur_entity.dart';
import '../providers/configuration_appareil_provider.dart';
import '../providers/mode_simulateur_provider.dart';
import 'diagnostic_bluetooth_screen.dart';

/// Sous-écran de l'étape Connexion : choisir l'appareil Bluetooth à
/// utiliser pour la connexion automatique, le mémoriser comme appareil par
/// défaut (persisté localement) et tester la connexion. Deux sources
/// d'appareils : ceux déjà appairés au système, et ceux trouvés par une
/// recherche active (voir _SectionDecouverte) — jamais une simple liste
/// statique quand le vrai Bluetooth est actif.
class ConfigurationAppareilScreen extends ConsumerWidget {
  const ConfigurationAppareilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(configurationAppareilProvider);
    final notifier = ref.read(configurationAppareilProvider.notifier);
    final modeSimulateur = ref.watch(modeSimulateurProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.configurationAppareilTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
        actions: [
          if (!modeSimulateur)
            IconButton(
              tooltip: l10n.diagnosticBluetoothLien,
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DiagnosticBluetoothScreen()),
              ),
            ),
        ],
      ),
      body: state.enChargement
          ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
          : RefreshIndicator(
              color: AppColors.vertOlive,
              onRefresh: notifier.charger,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _BandeauMode(modeSimulateur: modeSimulateur),
                  const SizedBox(height: 16),
                  Text(l10n.configurationAppareilTexteAide, style: AppTextStyles.sousTexteBienvenue),
                  const SizedBox(height: 20),
                  Text(l10n.appareilsAppairesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 15)),
                  const SizedBox(height: 8),
                  if (state.appareils.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          l10n.aucunAppareilAppaireTexte,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sousTexteBienvenue,
                        ),
                      ),
                    )
                  else
                    for (final appareil in state.appareils) ...[
                      _CarteAppareil(
                        appareil: appareil,
                        estParDefaut: state.adresseParDefaut == appareil.adresse,
                        enTest: state.adresseEnTest == appareil.adresse,
                        resultatTest: state.adresseDernierTest == appareil.adresse
                            ? state.dernierTestReussi
                            : null,
                        onChoisir: () => notifier.choisirAppareilParDefaut(appareil.adresse),
                        onTester: () => notifier.testerConnexion(appareil.adresse),
                      ),
                      const SizedBox(height: 12),
                    ],
                  if (state.adresseParDefaut != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: notifier.oublierAppareilParDefaut,
                        child: Text(l10n.oublierAppareilParDefautBouton),
                      ),
                    ),
                  ],
                  if (!modeSimulateur) ...[
                    const SizedBox(height: 28),
                    _SectionDecouverte(state: state, notifier: notifier),
                  ],
                ],
              ),
            ),
    );
  }
}

class _BandeauMode extends StatelessWidget {
  final bool modeSimulateur;

  const _BandeauMode({required this.modeSimulateur});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final couleur = modeSimulateur ? AppColors.orangeIcone : AppColors.bleuIcone;
    final fond = modeSimulateur ? AppColors.orangeFond : AppColors.bleuFond;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(modeSimulateur ? Icons.developer_mode_outlined : Icons.bluetooth, size: 16, color: couleur),
          const SizedBox(width: 8),
          Text(
            modeSimulateur ? l10n.modeActifBadgeSimulateur : l10n.modeActifBadgeBluetooth,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur),
          ),
        ],
      ),
    );
  }
}

class _CarteAppareil extends StatelessWidget {
  final AppareilAppaireEntity appareil;
  final bool estParDefaut;
  final bool enTest;
  final bool? resultatTest;
  final VoidCallback onChoisir;
  final VoidCallback onTester;

  const _CarteAppareil({
    required this.appareil,
    required this.estParDefaut,
    required this.enTest,
    required this.resultatTest,
    required this.onChoisir,
    required this.onTester,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InkWell(
      onTap: onChoisir,
      borderRadius: BorderRadius.circular(16),
      child: CarteStylisee(
        child: Row(
          children: [
            Icon(
              estParDefaut ? Icons.radio_button_checked : Icons.radio_button_off,
              color: estParDefaut ? AppColors.vertOlive : AppColors.grisMoyen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appareil.nom,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                  ),
                  Text(
                    appareil.adresse,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                  ),
                  if (resultatTest != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resultatTest! ? l10n.testConnexionReussi : l10n.testConnexionEchoue,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: resultatTest! ? AppColors.succes : AppColors.erreur,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            enTest
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                  )
                : TextButton(
                    onPressed: onTester,
                    child: Text(l10n.testerConnexionBouton, style: const TextStyle(fontSize: 12)),
                  ),
          ],
        ),
      ),
    );
  }
}

/// "Appareils détectés à proximité" (cahier des charges, section 4) : scan
/// actif, distinct de la liste des appareils déjà appairés — jamais
/// affichée en mode simulateur (aucun sens, voir le badge de mode).
class _SectionDecouverte extends StatelessWidget {
  final ConfigurationAppareilState state;
  final ConfigurationAppareilNotifier notifier;

  const _SectionDecouverte({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.appareilsProximiteTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 15)),
            ),
            if (state.enDecouverte)
              TextButton.icon(
                onPressed: notifier.arreterDecouverteManuelle,
                icon: const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.erreur),
                ),
                label: Text(l10n.arreterRechercheBouton, style: const TextStyle(color: AppColors.erreur)),
              )
            else
              TextButton.icon(
                onPressed: notifier.lancerDecouverte,
                icon: const Icon(Icons.search, size: 16),
                label: Text(l10n.rechercherAppareilsBouton),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bleuFond, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.bleuIcone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.avertissementBleTexte,
                  style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.erreurDecouverte != null)
          _BandeauCauseEchec(
            message: state.erreurDecouverte!,
            cause: state.causeErreurDecouverte,
            onReessayer: notifier.lancerDecouverte,
            onActiverBluetooth: () async {
              await notifier.activerBluetooth();
              await notifier.lancerDecouverte();
            },
          )
        else if (state.appareilsDecouverts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                l10n.aucunAppareilDetecteTexte,
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
            ),
          )
        else
          for (final appareil in state.appareilsDecouverts) ...[
            _CarteAppareilDecouvert(
              appareil: appareil,
              enAppairage: state.adresseEnAppairage == appareil.adresse,
              onAppairer: () => notifier.appairerEtDefinir(
                appareil.adresse,
                dejaAppaire: appareil.dejaAppaire,
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _CarteAppareilDecouvert extends StatelessWidget {
  final AppareilDecouvertEntity appareil;
  final bool enAppairage;
  final VoidCallback onAppairer;

  const _CarteAppareilDecouvert({
    required this.appareil,
    required this.enAppairage,
    required this.onAppairer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Row(
        children: [
          const Icon(Icons.bluetooth_searching, color: AppColors.bleuIcone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appareil.nom,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
                Text(appareil.adresse, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11)),
                Row(
                  children: [
                    if (appareil.forceSignal != null) ...[
                      const Icon(Icons.signal_cellular_alt, size: 12, color: AppColors.grisMoyen),
                      const SizedBox(width: 3),
                      Text(
                        '${appareil.forceSignal} dBm',
                        style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (appareil.dejaAppaire)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.evooFond,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.appareilDejaAppaireBadge,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          enAppairage
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                )
              : TextButton(
                  onPressed: onAppairer,
                  child: Text(
                    appareil.dejaAppaire ? l10n.definirParDefautBouton : l10n.appairerBouton,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
        ],
      ),
    );
  }
}

/// Bandeau actionnable pour chaque cause d'échec (cahier des charges,
/// section 3) : jamais un simple message inerte quand une action précise
/// peut réellement résoudre le blocage.
class _BandeauCauseEchec extends StatelessWidget {
  final String message;
  final CauseEchecConnexion? cause;
  final VoidCallback onReessayer;
  final VoidCallback onActiverBluetooth;

  const _BandeauCauseEchec({
    required this.message,
    required this.cause,
    required this.onReessayer,
    required this.onActiverBluetooth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (texte, bouton, action) = _resoudre(l10n);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.lampanteFond, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 18, color: AppColors.erreur),
              const SizedBox(width: 10),
              Expanded(
                child: Text(texte, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
              ),
            ],
          ),
          if (bouton != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: OutlinedButton(onPressed: action, child: Text(bouton, style: const TextStyle(fontSize: 12))),
            ),
          ],
        ],
      ),
    );
  }

  (String, String?, VoidCallback?) _resoudre(AppLocalizations l10n) {
    switch (cause) {
      case CauseEchecConnexion.bluetoothDesactive:
        return (l10n.causeBluetoothDesactiveTexte, l10n.boutonActiverBluetooth, onActiverBluetooth);
      case CauseEchecConnexion.permissionRefusee:
        return (l10n.causePermissionRefuseeTexte, l10n.boutonAutoriser, onReessayer);
      case CauseEchecConnexion.permissionRefuseeDefinitivement:
        return (
          l10n.causePermissionRefuseeDefinitivementTexte,
          l10n.boutonOuvrirReglages,
          () => openAppSettings(),
        );
      case CauseEchecConnexion.localisationDesactivee:
        return (
          l10n.causeLocalisationDesactiveeTexte,
          l10n.boutonActiverLocalisation,
          () => Geolocator.openLocationSettings(),
        );
      case CauseEchecConnexion.appareilIntrouvable:
      case CauseEchecConnexion.autre:
      case null:
        return (message, null, null);
    }
  }
}
