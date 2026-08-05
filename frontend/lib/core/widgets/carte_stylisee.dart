import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Conteneur de carte réutilisé dans toute l'application (fond blanc, coins
/// arrondis, bordure fine, ombre subtile) : dashboard, paramètres, etc.
class CarteStylisee extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CarteStylisee({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grisLigne),
        boxShadow: const [BoxShadow(color: AppColors.ombre, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}
