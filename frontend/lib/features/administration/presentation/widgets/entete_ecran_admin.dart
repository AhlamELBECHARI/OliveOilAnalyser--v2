import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

/// En-tête d'AppBar commun aux 5 onglets de l'espace admin — badge d'icône
/// coloré + titre + sous-titre, pour ne pas laisser un simple libellé seul
/// en haut de l'écran (voir Dashboard/Historique côté utilisateur, qui ont
/// tous les deux une identité visuelle plus riche qu'un titre nu).
class EnTeteEcranAdmin extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String sousTitre;

  const EnTeteEcranAdmin({
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icon(icone, color: couleur, size: 17),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: AppTextStyles.bienvenue.copyWith(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sousTitre,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
