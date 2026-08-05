import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Une ligne de sélection de langue : libellé dans sa propre langue, coche
/// si active.
class OptionLangue extends StatelessWidget {
  final String libelle;
  final bool active;
  final VoidCallback onTap;

  const OptionLangue({
    super.key,
    required this.libelle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                libelle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.grisFonce,
                ),
              ),
            ),
            if (active) const Icon(Icons.check_circle, color: AppColors.vertOlive, size: 22),
          ],
        ),
      ),
    );
  }
}
