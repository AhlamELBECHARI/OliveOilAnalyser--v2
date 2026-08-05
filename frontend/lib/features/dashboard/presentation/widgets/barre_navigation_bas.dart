import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class _OngletNavigation {
  final IconData icone;
  final String Function(AppLocalizations) libelle;

  const _OngletNavigation(this.icone, this.libelle);
}

const _onglets = [
  _OngletNavigation(Icons.home_rounded, _libelleAccueil),
  _OngletNavigation(Icons.show_chart, _libelleAnalyse),
  _OngletNavigation(Icons.description_outlined, _libelleHistorique),
  _OngletNavigation(Icons.insights_outlined, _libelleModeles),
  _OngletNavigation(Icons.settings_outlined, _libelleParametres),
];

String _libelleAccueil(AppLocalizations l10n) => l10n.navAccueil;
String _libelleAnalyse(AppLocalizations l10n) => l10n.navAnalyse;
String _libelleHistorique(AppLocalizations l10n) => l10n.navHistorique;
String _libelleModeles(AppLocalizations l10n) => l10n.navModeles;
String _libelleParametres(AppLocalizations l10n) => l10n.navParametres;

/// Barre de navigation inférieure. Seul "Accueil" (le dashboard) et
/// "Paramètres" sont implémentés pour l'instant ; les autres modules
/// n'existent pas encore.
class BarreNavigationBas extends StatelessWidget {
  final int indexActif;
  final void Function(int)? onTap;

  const BarreNavigationBas({super.key, this.indexActif = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        border: Border(top: BorderSide(color: AppColors.grisLigne)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _onglets.length; i++)
              Expanded(
                child: _BoutonOnglet(
                  onglet: _onglets[i],
                  actif: i == indexActif,
                  onTap: onTap == null ? null : () => onTap!(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BoutonOnglet extends StatelessWidget {
  final _OngletNavigation onglet;
  final bool actif;
  final VoidCallback? onTap;

  const _BoutonOnglet({required this.onglet, required this.actif, this.onTap});

  @override
  Widget build(BuildContext context) {
    final couleur = actif ? AppColors.vertOlive : AppColors.grisMoyen;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(onglet.icone, color: couleur, size: 24),
            const SizedBox(height: 2),
            Text(
              onglet.libelle(context.l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: couleur,
                fontWeight: actif ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
