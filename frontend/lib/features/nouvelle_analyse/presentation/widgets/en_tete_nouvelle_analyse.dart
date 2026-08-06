import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../analyseur/domain/entities/etat_connexion_analyseur_entity.dart';

/// En-tête de l'écran Nouvelle Analyse : logo, titre, et badge de connexion
/// RÉEL à l'analyseur (jamais une valeur fixe "Connecté") — voir
/// NouvelleAnalyseNotifier, abonné à AnalyseurRepository.flusEtatConnexion.
class EnTeteNouvelleAnalyse extends StatelessWidget {
  final EtatConnexionAnalyseurEntity etatConnexion;
  final VoidCallback onTapScan;

  const EnTeteNouvelleAnalyse({
    super.key,
    required this.etatConnexion,
    required this.onTapScan,
  });

  Color get _couleur => switch (etatConnexion.etat) {
        EtatConnexion.connecte => AppColors.succes,
        EtatConnexion.recherche => AppColors.orangeIcone,
        EtatConnexion.erreur => AppColors.erreur,
        EtatConnexion.deconnecte => AppColors.grisMoyen,
      };

  String _libelle(BuildContext context) {
    final l10n = context.l10n;
    return switch (etatConnexion.etat) {
      EtatConnexion.connecte => l10n.connecte,
      EtatConnexion.recherche => l10n.etatRecherche,
      EtatConnexion.erreur => l10n.etatErreurConnexion,
      EtatConnexion.deconnecte => l10n.deconnecte,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: AppColors.evooFond, shape: BoxShape.circle),
          child: const Icon(Icons.science_outlined, color: AppColors.vertOliveFonce, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.nouvelleAnalyseTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
              Text(
                l10n.nouvelleAnalyseSousTitre,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _couleur.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _couleur, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                _libelle(context),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _couleur),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onTapScan,
          icon: const Icon(Icons.bluetooth_searching, color: AppColors.grisFonce),
          tooltip: l10n.reessayerConnexionBouton,
        ),
      ],
    );
  }
}
