import 'package:flutter/material.dart';

/// Palette de couleurs centralisée d'Olive IQ, reprise des maquettes
/// design/1-login.png et design/2-dashboard.png. Aucune couleur codée en dur
/// ne doit apparaître ailleurs dans les widgets.
class AppColors {
  const AppColors._();

  static const Color fond = Color(0xFFF7F6F2);
  static const Color vertOliveFonce = Color(0xFF2D4A22);
  static const Color vertOlive = Color(0xFF6B8B3D);
  static const Color grisFonce = Color(0xFF333333);
  static const Color grisMoyen = Color(0xFF757575);
  static const Color grisClair = Color(0xFFBDBDBD);
  static const Color grisLigne = Color(0xFFE0E0E0);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color erreur = Color(0xFFC0392B);
  static const Color ombre = Color(0x14000000);

  // --- Dashboard : catégories de qualité ---
  static const Color evoo = vertOlive;
  static const Color voo = Color(0xFFE0A72E);
  static const Color lampante = Color(0xFFD9534F);

  static const Color evooFond = Color(0xFFE7EFDC);
  static const Color vooFond = Color(0xFFFBEFDA);
  static const Color lampanteFond = Color(0xFFF9E1DF);

  // --- Dashboard : icônes de cartes ---
  static const Color bleuIcone = Color(0xFF4A7BA6);
  static const Color bleuFond = Color(0xFFDEEAF7);
  static const Color orangeIcone = Color(0xFFD07A2E);
  static const Color orangeFond = Color(0xFFFBEFDA);

  static const Color succes = Color(0xFF3D8B4A);
}
