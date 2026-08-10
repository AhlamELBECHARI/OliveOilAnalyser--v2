import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/appareil_appaire_entity.dart';
import '../providers/configuration_appareil_provider.dart';

/// Sous-écran de l'étape Connexion : choisir l'appareil Bluetooth déjà
/// appairé à utiliser pour la connexion automatique, le mémoriser comme
/// appareil par défaut (persisté localement) et tester la connexion. Ne
/// fait jamais de scan/découverte — seulement les appareils déjà appairés
/// dans les réglages Bluetooth du téléphone.
class ConfigurationAppareilScreen extends ConsumerWidget {
  const ConfigurationAppareilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(configurationAppareilProvider);
    final notifier = ref.read(configurationAppareilProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.configurationAppareilTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: state.enChargement
          ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
          : RefreshIndicator(
              color: AppColors.vertOlive,
              onRefresh: notifier.charger,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(l10n.configurationAppareilTexteAide, style: AppTextStyles.sousTexteBienvenue),
                  const SizedBox(height: 16),
                  if (state.appareils.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
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
                ],
              ),
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
