import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Badge d'icône + titre + sous-titre en tête d'écran — le même vocabulaire
/// que EnTeteNouvelleAnalyse et le bandeau "Mon Profil" de ProfilScreen
/// (icône 44px, titre 20, sous-titre 12), pour que tous les onglets aient
/// une identité visuelle cohérente au lieu d'un simple libellé nu.
class EnTeteEcran extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String sousTitre;

  const EnTeteEcran({
    super.key,
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.titre,
    required this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icon(icone, color: couleur, size: 22),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: AppTextStyles.bienvenue.copyWith(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sousTitre,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
