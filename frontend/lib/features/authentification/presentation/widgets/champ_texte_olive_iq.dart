import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Champ de saisie au style de la maquette login : fond blanc, coins
/// arrondis, ombre subtile, icône verte à gauche.
class ChampTexteOliveIQ extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icone;
  final bool masquerTexte;
  final Widget? suffixe;
  final TextInputType? clavier;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const ChampTexteOliveIQ({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icone,
    this.masquerTexte = false,
    this.suffixe,
    this.clavier,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grisLigne, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ombre,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: masquerTexte,
        keyboardType: clavier,
        validator: validator,
        autovalidateMode: autovalidateMode,
        style: AppTextStyles.champTexte,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.champPlaceholder,
          prefixIcon: Icon(icone, color: AppColors.vertOlive),
          suffixIcon: suffixe,
          filled: false,
          border: InputBorder.none,
          errorStyle: AppTextStyles.erreurChamp,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        ),
      ),
    );
  }
}
