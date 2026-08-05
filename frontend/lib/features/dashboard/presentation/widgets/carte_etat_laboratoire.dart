import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/etat_analyseur_entity.dart';
import '../../../../core/widgets/carte_stylisee.dart';

/// Carte "État du laboratoire" : reflète l'état RÉEL de la connexion à
/// l'analyseur Bluetooth, via [EtatAnalyseurEntity] (voir
/// domain/repositories/etat_analyseur_repository.dart pour l'abstraction
/// derrière laquelle une vraie implémentation Bluetooth sera branchée).
class CarteEtatLaboratoire extends StatelessWidget {
  final EtatAnalyseurEntity etat;

  const CarteEtatLaboratoire({super.key, required this.etat});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: etat.estOperationnel ? AppColors.succes : AppColors.erreur,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.etatLaboratoire,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                etat.estOperationnel ? l10n.operationnel : l10n.horsLigne,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: etat.estOperationnel ? AppColors.succes : AppColors.erreur,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Colonne(
                    icone: Icons.memory,
                    libelle: l10n.appareilConnecteLabel,
                    valeur: etat.appareilConnecte ? (etat.nomAppareil ?? l10n.connecte) : l10n.aucun,
                  ),
                ),
                const VerticalDivider(color: AppColors.grisLigne, width: 1),
                Expanded(
                  child: _Colonne(
                    icone: Icons.bluetooth,
                    libelle: l10n.bluetooth,
                    valeur: etat.bluetoothActif ? l10n.connecte : l10n.deconnecte,
                    valeurEnCouleur: etat.bluetoothActif,
                  ),
                ),
                const VerticalDivider(color: AppColors.grisLigne, width: 1),
                Expanded(
                  child: _Colonne(
                    icone: Icons.battery_std,
                    libelle: l10n.batterie,
                    valeur: etat.niveauBatteriePourcentage != null
                        ? '${etat.niveauBatteriePourcentage}%'
                        : '—',
                  ),
                ),
                const VerticalDivider(color: AppColors.grisLigne, width: 1),
                Expanded(
                  child: _Colonne(
                    icone: Icons.sync,
                    libelle: l10n.derniereSynchro,
                    valeur: etat.derniereSynchronisation != null
                        ? _formaterSynchronisation(etat.derniereSynchronisation!, l10n)
                        : '—',
                    valeurEnCouleur: etat.derniereSynchronisation != null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formaterSynchronisation(DateTime instant, AppLocalizations l10n) {
    final maintenant = DateTime.now();
    final estAujourdHui = instant.year == maintenant.year &&
        instant.month == maintenant.month &&
        instant.day == maintenant.day;
    final heure = DateFormat.Hm(l10n.localeName).format(instant);
    if (estAujourdHui) {
      return l10n.aujourdHuiHeure(heure);
    }
    final date = DateFormat.Md(l10n.localeName).format(instant);
    return l10n.dateEtHeure(date, heure);
  }
}

class _Colonne extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final String valeur;
  final bool valeurEnCouleur;

  const _Colonne({
    required this.icone,
    required this.libelle,
    required this.valeur,
    this.valeurEnCouleur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: AppColors.evooFond, shape: BoxShape.circle),
          child: Icon(icone, color: AppColors.vertOliveFonce, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          libelle,
          textAlign: TextAlign.center,
          style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          valeur,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valeurEnCouleur ? AppColors.succes : AppColors.grisFonce,
          ),
        ),
      ],
    );
  }
}
