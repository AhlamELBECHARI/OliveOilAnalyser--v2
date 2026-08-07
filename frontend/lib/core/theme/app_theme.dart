import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Thèmes clair et sombre de l'app (voir Partie B, section "Préférences").
///
/// IMPORTANT — portée de cette préparation : la plupart des écrans
/// existants utilisent encore des couleurs fixes de AppColors (jamais
/// `Theme.of(context)`), écrites avant que le thème sombre ne soit demandé.
/// [themeSombre] ci-dessous fournit une ColorScheme et un Material Theme
/// sombres complets et sélectionnables (bascule immédiate, préférence
/// persistée — voir ThemeModeNotifier), mais tant que ces écrans n'ont pas
/// été migrés pour lire leurs couleurs depuis le ColorScheme plutôt que
/// AppColors en dur, ils resteront visuellement clairs même en mode sombre.
/// Ce fichier est le point d'extension unique pour cette migration
/// progressive : aucun autre fichier ne doit définir de ThemeData.
class AppTheme {
  const AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.fond,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vertOlive,
        primary: AppColors.vertOlive,
        surface: AppColors.fond,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.titreLogo,
        titleLarge: AppTextStyles.bienvenue,
        bodyMedium: AppTextStyles.champTexte,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fond,
        foregroundColor: AppColors.grisFonce,
        elevation: 0,
      ),
    );
  }

  static ThemeData get themeSombre {
    const fondSombre = Color(0xFF14170F);
    const surfaceSombre = Color(0xFF1E2318);
    const texteClairSombre = Color(0xFFEDEEE9);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: fondSombre,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vertOlive,
        brightness: Brightness.dark,
        primary: AppColors.vertOlive,
        surface: surfaceSombre,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.titreLogo.copyWith(color: texteClairSombre),
        titleLarge: AppTextStyles.bienvenue.copyWith(color: texteClairSombre),
        bodyMedium: AppTextStyles.champTexte.copyWith(color: texteClairSombre),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: fondSombre,
        foregroundColor: texteClairSombre,
        elevation: 0,
      ),
      cardColor: surfaceSombre,
      dividerColor: const Color(0xFF33392A),
    );
  }
}
