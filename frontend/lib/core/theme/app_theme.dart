import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
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
}
