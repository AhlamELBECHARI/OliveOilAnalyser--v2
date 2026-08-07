import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';

Color couleurCategorie(CategorieQualiteHistorique categorie) => switch (categorie) {
      CategorieQualiteHistorique.evoo => AppColors.evoo,
      CategorieQualiteHistorique.voo => AppColors.voo,
      CategorieQualiteHistorique.lampante => AppColors.lampante,
    };

Color fondCategorie(CategorieQualiteHistorique categorie) => switch (categorie) {
      CategorieQualiteHistorique.evoo => AppColors.evooFond,
      CategorieQualiteHistorique.voo => AppColors.vooFond,
      CategorieQualiteHistorique.lampante => AppColors.lampanteFond,
    };

IconData _iconeCategorie(CategorieQualiteHistorique categorie) => switch (categorie) {
      CategorieQualiteHistorique.evoo => Icons.check_circle,
      CategorieQualiteHistorique.voo => Icons.circle,
      CategorieQualiteHistorique.lampante => Icons.warning_rounded,
    };

/// Libellé court (badge de catégorie des lignes de la liste) — vient
/// toujours des fichiers ARB, jamais du texte renvoyé par le backend.
String libelleCourtCategorieHistorique(CategorieQualiteHistorique categorie, BuildContext context) {
  final l10n = context.l10n;
  return switch (categorie) {
    CategorieQualiteHistorique.evoo => l10n.categorieEvooCourt,
    CategorieQualiteHistorique.voo => l10n.categorieVooCourt,
    CategorieQualiteHistorique.lampante => l10n.categorieLampanteCourt,
  };
}

/// Carte "Aperçu" (design/4-historiques.png) : 5 indicateurs — total,
/// répartition qualité (3) et analyses ce mois — alignés en une seule
/// rangée compacte, chacun avec son icône ronde au-dessus de la valeur,
/// séparés par de fins traits verticaux. Défile horizontalement plutôt que
/// de s'étirer verticalement sur un écran étroit.
class CarteApercuHistorique extends StatelessWidget {
  final ApercuHistoriqueEntity apercu;

  const CarteApercuHistorique({super.key, required this.apercu});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatNombre = NumberFormat.decimalPattern(l10n.localeName);
    final formatPourcentage = NumberFormat('#,##0.0', l10n.localeName);
    final variationCeMois = apercu.ceMois.variationPourcentage;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.apercuTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IndicateurApercu(
                    icone: Icons.science_outlined,
                    couleur: AppColors.vertOliveFonce,
                    fond: AppColors.evooFond,
                    valeur: formatNombre.format(apercu.totalAnalyses),
                    libelle: l10n.totalAnalysesLabel,
                  ),
                  for (final item in apercu.repartitionQualite) ...[
                    const _SeparateurVertical(),
                    _IndicateurApercu(
                      icone: _iconeCategorie(item.categorie),
                      couleur: couleurCategorie(item.categorie),
                      fond: fondCategorie(item.categorie),
                      valeur: formatNombre.format(item.effectif),
                      libelle: item.libelle,
                      sousTexte: '${formatPourcentage.format(item.pourcentage)}%',
                      couleurSousTexte: couleurCategorie(item.categorie),
                    ),
                  ],
                  const _SeparateurVertical(),
                  _IndicateurApercu(
                    icone: Icons.calendar_today_outlined,
                    couleur: AppColors.bleuIcone,
                    fond: AppColors.bleuFond,
                    valeur: formatNombre.format(apercu.ceMois.valeur),
                    libelle: l10n.ceMoisLabel,
                    sousTexte: variationCeMois == null
                        ? null
                        : '${variationCeMois >= 0 ? '↑' : '↓'} ${formatPourcentage.format(variationCeMois.abs())}%',
                    couleurSousTexte: variationCeMois == null
                        ? null
                        : (variationCeMois >= 0 ? AppColors.succes : AppColors.erreur),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeparateurVertical extends StatelessWidget {
  const _SeparateurVertical();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: VerticalDivider(width: 1, thickness: 1, color: AppColors.grisLigne),
    );
  }
}

class _IndicateurApercu extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String valeur;
  final String libelle;
  final String? sousTexte;
  final Color? couleurSousTexte;

  const _IndicateurApercu({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.valeur,
    required this.libelle,
    this.sousTexte,
    this.couleurSousTexte,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
            child: Icon(icone, color: couleur, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            valeur,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 2),
          Text(
            libelle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
          ),
          if (sousTexte != null) ...[
            const SizedBox(height: 2),
            Text(
              sousTexte!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleurSousTexte),
            ),
          ],
        ],
      ),
    );
  }
}
