import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/statistiques_dashboard_entity.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import 'carte_qualite_huiles.dart' show libelleCourtCategorie;

Color _couleurCategorie(CategorieQualite categorie) {
  switch (categorie) {
    case CategorieQualite.evoo:
      return AppColors.evoo;
    case CategorieQualite.voo:
      return AppColors.voo;
    case CategorieQualite.lampante:
      return AppColors.lampante;
  }
}

Color _fondCategorie(CategorieQualite categorie) {
  switch (categorie) {
    case CategorieQualite.evoo:
      return AppColors.evooFond;
    case CategorieQualite.voo:
      return AppColors.vooFond;
    case CategorieQualite.lampante:
      return AppColors.lampanteFond;
  }
}

/// Carte "Activité récente" : liste des dernières analyses avec badge de
/// catégorie coloré.
class CarteActiviteRecente extends StatelessWidget {
  final List<AnalyseRecenteEntity> analyses;
  final VoidCallback? onVoirHistorique;
  final void Function(AnalyseRecenteEntity)? onTapAnalyse;

  const CarteActiviteRecente({
    super.key,
    required this.analyses,
    this.onVoirHistorique,
    this.onTapAnalyse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.activiteRecente,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
            ),
          ),
          const SizedBox(height: 8),
          if (analyses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(l10n.aucuneAnalyseRecente, style: AppTextStyles.sousTexteBienvenue),
            )
          else
            for (final analyse in analyses)
              InkWell(
                onTap: onTapAnalyse == null ? null : () => onTapAnalyse!(analyse),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _LigneAnalyse(analyse: analyse),
                ),
              ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onVoirHistorique,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.voirToutHistorique,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.vertOlive),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.vertOlive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneAnalyse extends StatelessWidget {
  final AnalyseRecenteEntity analyse;

  const _LigneAnalyse({required this.analyse});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final couleur = _couleurCategorie(analyse.categorie);
    final fond = _fondCategorie(analyse.categorie);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icon(Icons.science_outlined, color: couleur, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analyse.numero,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
              ),
              const SizedBox(height: 2),
              Text(
                '${analyse.origine} • ${analyse.variete}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(analyse.heure, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(8)),
          child: Text(
            libelleCourtCategorie(analyse.categorie, l10n),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.grisClair),
      ],
    );
  }
}
