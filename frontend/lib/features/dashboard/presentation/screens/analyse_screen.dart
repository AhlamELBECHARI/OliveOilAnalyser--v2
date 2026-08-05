import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Écran "Nouvelle analyse". Ne dépend d'aucune donnée factice : l'état
/// vide affiché ici reflète une réalité technique (le module Bluetooth qui
/// pilotera l'analyseur spectroscopique n'est pas encore développé — voir
/// EtatAnalyseurRepository), pas un placeholder générique "bientôt".
class AnalyseScreen extends StatelessWidget {
  const AnalyseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.navAnalyse, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bluetooth_disabled, size: 48, color: AppColors.grisMoyen),
              const SizedBox(height: 16),
              Text(
                l10n.analyseEnAttenteTitre,
                textAlign: TextAlign.center,
                style: AppTextStyles.bienvenue.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.analyseEnAttenteTexte,
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
