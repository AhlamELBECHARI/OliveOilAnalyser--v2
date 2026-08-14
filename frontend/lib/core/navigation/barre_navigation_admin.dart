import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../localization/build_context_l10n_extension.dart';
import '../theme/app_colors.dart';

class _OngletNavigationAdmin {
  final IconData icone;
  final String Function(AppLocalizations) libelle;

  const _OngletNavigationAdmin(this.icone, this.libelle);
}

const _ongletsAdmin = [
  _OngletNavigationAdmin(Icons.dashboard_outlined, _libelleSupervision),
  _OngletNavigationAdmin(Icons.people_outline, _libelleUtilisateurs),
  _OngletNavigationAdmin(Icons.description_outlined, _libelleAnalyses),
  _OngletNavigationAdmin(Icons.insights_outlined, _libelleModeles),
  _OngletNavigationAdmin(Icons.admin_panel_settings_outlined, _libelleAdministration),
];

String _libelleSupervision(AppLocalizations l10n) => l10n.navSupervision;
String _libelleUtilisateurs(AppLocalizations l10n) => l10n.navUtilisateurs;
String _libelleAnalyses(AppLocalizations l10n) => l10n.navAnalyses;
String _libelleModeles(AppLocalizations l10n) => l10n.navModeles;
String _libelleAdministration(AppLocalizations l10n) => l10n.navAdministration;

/// Barre de navigation de l'espace admin — 5 onglets distincts de la
/// coquille utilisateur (voir BarreNavigationBas), jamais mélangés : un
/// administrateur ne voit jamais l'application utilisateur enrichie.
class BarreNavigationAdmin extends StatelessWidget {
  final int indexActif;
  final void Function(int)? onTap;

  const BarreNavigationAdmin({super.key, this.indexActif = 0, this.onTap});

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
            for (var i = 0; i < _ongletsAdmin.length; i++)
              Expanded(
                child: _BoutonOngletAdmin(
                  onglet: _ongletsAdmin[i],
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

class _BoutonOngletAdmin extends StatelessWidget {
  final _OngletNavigationAdmin onglet;
  final bool actif;
  final VoidCallback? onTap;

  const _BoutonOngletAdmin({required this.onglet, required this.actif, this.onTap});

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
