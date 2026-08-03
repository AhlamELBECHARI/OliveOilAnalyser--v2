import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Styles de texte centralisés d'Olive IQ.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle titreLogo = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.vertOliveFonce,
    letterSpacing: -0.5,
  );

  static const TextStyle sousTitreLogo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grisMoyen,
  );

  static const TextStyle bienvenue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.grisFonce,
  );

  static const TextStyle sousTexteBienvenue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.grisMoyen,
  );

  static const TextStyle champTexte = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grisFonce,
  );

  static const TextStyle champPlaceholder = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grisMoyen,
  );

  static const TextStyle lienAction = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.vertOlive,
  );

  static const TextStyle boutonPrincipal = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.blanc,
  );

  static const TextStyle boutonSecondaire = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.vertOlive,
  );

  static const TextStyle separateur = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grisMoyen,
  );

  static const TextStyle version = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.grisClair,
  );

  static const TextStyle erreurChamp = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.erreur,
  );
}
