import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Une ligne de réglage générique (icône ronde, titre, sous-titre, contenu
/// de fin — texte/interrupteur, chevron optionnel) réutilisée dans tout
/// l'écran Profil : Compte, Préférences, Données & Synchronisation, À
/// propos (design/6-profil.png).
class LigneParametre extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final Widget? fin;
  final VoidCallback? onTap;
  final bool desactive;

  const LigneParametre({
    super.key,
    required this.icone,
    required this.titre,
    this.sousTitre,
    this.fin,
    this.onTap,
    this.desactive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: desactive ? 0.5 : 1,
      child: InkWell(
        onTap: desactive ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: AppColors.evooFond, shape: BoxShape.circle),
                child: Icon(icone, color: AppColors.vertOliveFonce, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                    ),
                    if (sousTitre != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sousTitre!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (fin != null) fin!,
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.grisClair),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
