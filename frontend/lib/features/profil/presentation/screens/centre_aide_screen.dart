import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';

/// Sous-écran "Centre d'aide" — contenu statique pour l'instant (voir
/// Partie B du cahier des charges).
class CentreAideScreen extends StatelessWidget {
  const CentreAideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.centreAideTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CarteStylisee(
            child: Text(
              l10n.centreAideContenu,
              style: const TextStyle(fontSize: 14, color: AppColors.grisFonce, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
