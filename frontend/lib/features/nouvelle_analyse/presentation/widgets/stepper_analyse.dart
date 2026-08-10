import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/nouvelle_analyse_provider.dart';

/// Stepper visuel à 3 étapes (design/3-analyse.png) : purement dérivé de
/// [etapeCourante] (voir NouvelleAnalyseState.etapeCourante), jamais un
/// compteur manipulé indépendamment de l'avancement réel de l'écran.
class StepperAnalyse extends StatelessWidget {
  final EtapeAnalyse etapeCourante;

  const StepperAnalyse({super.key, required this.etapeCourante});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final etapes = [
      (EtapeAnalyse.connexion, l10n.etapeConnexionLabel),
      (EtapeAnalyse.echantillon, l10n.etapeEchantillonLabel),
      (EtapeAnalyse.analyse, l10n.etapeAnalyseLabel),
      (EtapeAnalyse.resultats, l10n.etapeResultatsLabel),
    ];

    return Row(
      children: [
        for (var i = 0; i < etapes.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: etapes[i].$1.index <= etapeCourante.index
                    ? AppColors.vertOlive
                    : AppColors.grisLigne,
              ),
            ),
          _Pastille(
            numero: i + 1,
            libelle: etapes[i].$2,
            etat: _etatDe(etapes[i].$1),
          ),
        ],
      ],
    );
  }

  _EtatPastille _etatDe(EtapeAnalyse etape) {
    if (etape.index < etapeCourante.index) return _EtatPastille.complete;
    if (etape.index == etapeCourante.index) return _EtatPastille.active;
    return _EtatPastille.aVenir;
  }
}

enum _EtatPastille { complete, active, aVenir }

class _Pastille extends StatelessWidget {
  final int numero;
  final String libelle;
  final _EtatPastille etat;

  const _Pastille({required this.numero, required this.libelle, required this.etat});

  @override
  Widget build(BuildContext context) {
    final couleurFond = switch (etat) {
      _EtatPastille.complete => AppColors.vertOlive,
      _EtatPastille.active => AppColors.vertOlive,
      _EtatPastille.aVenir => AppColors.grisLigne,
    };
    final couleurTexte = etat == _EtatPastille.aVenir ? AppColors.grisMoyen : AppColors.blanc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: couleurFond, shape: BoxShape.circle),
          child: etat == _EtatPastille.complete
              ? const Icon(Icons.check, size: 18, color: AppColors.blanc)
              : Text(
                  '$numero',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: couleurTexte),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          libelle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: etat == _EtatPastille.active ? FontWeight.w700 : FontWeight.w400,
            color: etat == _EtatPastille.aVenir ? AppColors.grisMoyen : AppColors.grisFonce,
          ),
        ),
      ],
    );
  }
}
