import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/diagnostic_bluetooth_entity.dart';
import '../providers/configuration_appareil_provider.dart';

/// Écran de diagnostic Bluetooth (cahier des charges, section 5) : donne en
/// un coup d'œil l'état de l'adaptateur, de chaque permission, du service de
/// localisation et du dernier balayage — pour comprendre pourquoi aucun
/// appareil n'apparaît sans jamais avoir à lire les journaux. Réutilise
/// [configurationAppareilProvider] (poussé par-dessus l'écran de
/// configuration, qui reste en vie dans l'arbre et garde l'instance active).
class DiagnosticBluetoothScreen extends ConsumerStatefulWidget {
  const DiagnosticBluetoothScreen({super.key});

  @override
  ConsumerState<DiagnosticBluetoothScreen> createState() => _DiagnosticBluetoothScreenState();
}

class _DiagnosticBluetoothScreenState extends ConsumerState<DiagnosticBluetoothScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(configurationAppareilProvider.notifier).chargerDiagnostic());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diagnostic = ref.watch(configurationAppareilProvider).diagnostic;
    final notifier = ref.read(configurationAppareilProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.diagnosticBluetoothTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: diagnostic == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
          : RefreshIndicator(
              color: AppColors.vertOlive,
              onRefresh: notifier.chargerDiagnostic,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(l10n.diagnosticBluetoothSousTitre, style: AppTextStyles.sousTexteBienvenue),
                  const SizedBox(height: 16),
                  if (diagnostic.toutEstOperationnel)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.succes.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.succes),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.diagnosticToutOperationnelTexte,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.succes),
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
                        _LigneDiagnostic(
                          libelle: l10n.diagnosticAdaptateurLabel,
                          valeur: switch (diagnostic.etatAdaptateur) {
                            EtatAdaptateurBluetooth.actif => l10n.diagnosticAdaptateurActif,
                            EtatAdaptateurBluetooth.inactif => l10n.diagnosticAdaptateurInactif,
                            EtatAdaptateurBluetooth.inconnu => l10n.diagnosticAdaptateurInconnu,
                          },
                          ok: diagnostic.etatAdaptateur == EtatAdaptateurBluetooth.actif,
                        ),
                        if (diagnostic.etatAdaptateur == EtatAdaptateurBluetooth.inactif) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: notifier.activerBluetooth,
                              child: Text(l10n.boutonActiverBluetooth),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.diagnosticPermissionsTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 15)),
                  const SizedBox(height: 8),
                  CarteStylisee(
                    child: Column(
                      children: [
                        for (final permission in diagnostic.permissions) ...[
                          _LigneDiagnostic(
                            libelle: _libellePermission(l10n, permission.type),
                            valeur: _libelleEtatPermission(l10n, permission.etat),
                            ok: permission.etat == EtatPermission.accordee,
                          ),
                          if (permission != diagnostic.permissions.last)
                            const Divider(height: 20, color: AppColors.grisLigne),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CarteStylisee(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LigneDiagnostic(
                          libelle: diagnostic.localisationRequise
                              ? l10n.diagnosticServiceLocalisationLabel
                              : '${l10n.diagnosticServiceLocalisationLabel} (${l10n.diagnosticLocalisationNonRequiseTexte})',
                          valeur: diagnostic.serviceLocalisationActif
                              ? l10n.diagnosticServiceActif
                              : l10n.diagnosticServiceInactif,
                          ok: !diagnostic.localisationRequise || diagnostic.serviceLocalisationActif,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CarteStylisee(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LigneDiagnostic(
                          libelle: l10n.diagnosticNombreAppareilsLabel,
                          valeur: '${diagnostic.nombreAppareilsClassicDetectes}',
                          ok: null,
                        ),
                        const SizedBox(height: 8),
                        _LigneDiagnostic(
                          libelle: l10n.diagnosticDernierBalayageLabel,
                          valeur: diagnostic.dateDernierBalayage == null
                              ? l10n.diagnosticJamaisBalaye
                              : DateFormat.Hms(l10n.localeName).format(diagnostic.dateDernierBalayage!),
                          ok: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.orangeFond,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.orangeIcone),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.diagnosticMessageBleTexte,
                            style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: notifier.chargerDiagnostic,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.diagnosticRafraichirBouton),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _libellePermission(AppLocalizations l10n, PermissionBluetooth type) {
    switch (type) {
      case PermissionBluetooth.bluetoothScan:
        return l10n.diagnosticPermissionBluetoothScan;
      case PermissionBluetooth.bluetoothConnect:
        return l10n.diagnosticPermissionBluetoothConnect;
      case PermissionBluetooth.localisation:
        return l10n.diagnosticPermissionLocalisation;
    }
  }

  String _libelleEtatPermission(AppLocalizations l10n, EtatPermission etat) {
    switch (etat) {
      case EtatPermission.accordee:
        return l10n.diagnosticPermissionAccordee;
      case EtatPermission.refusee:
        return l10n.diagnosticPermissionRefusee;
      case EtatPermission.refuseeDefinitivement:
        return l10n.diagnosticPermissionRefuseeDefinitivement;
    }
  }
}

class _LigneDiagnostic extends StatelessWidget {
  final String libelle;
  final String valeur;
  final bool? ok;

  const _LigneDiagnostic({required this.libelle, required this.valeur, required this.ok});

  @override
  Widget build(BuildContext context) {
    final couleur = ok == null ? AppColors.grisFonce : (ok! ? AppColors.succes : AppColors.erreur);
    return Row(
      children: [
        if (ok != null) ...[
          Icon(
            ok! ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: couleur,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            libelle,
            style: const TextStyle(fontSize: 13, color: AppColors.grisFonce),
          ),
        ),
        Text(
          valeur,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: couleur),
        ),
      ],
    );
  }
}
