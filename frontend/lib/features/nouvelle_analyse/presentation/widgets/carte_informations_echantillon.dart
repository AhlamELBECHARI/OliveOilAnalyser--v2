import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/nouvel_echantillon_entity.dart';
import '../providers/nouvelle_analyse_provider.dart';

/// Carte "Informations Échantillon" : s'ouvre volontairement en formulaire
/// VIDE (contrairement à design/3-analyse.png, qui montre l'état après
/// validation) — voir Partie A du cahier des charges. Bascule en
/// consultation (grille 2 colonnes façon maquette) une fois validée.
class CarteInformationsEchantillon extends StatelessWidget {
  final ModeCarteEchantillon mode;
  final NouvelEchantillonEntity brouillon;
  final NouvelEchantillonEntity? echantillonValide;
  final bool enregistrementEnCours;
  final bool positionEnCoursDeChargement;
  final String? echecPosition;
  final ValueChanged<String> onChangerNumero;
  final ValueChanged<String> onChangerProducteur;
  final ValueChanged<String> onChangerVariete;
  final ValueChanged<String> onChangerRegion;
  final ValueChanged<DateTime> onChangerDateRecolte;
  final VoidCallback onPositionActuelle;
  final VoidCallback onValider;
  final VoidCallback onModifier;

  const CarteInformationsEchantillon({
    super.key,
    required this.mode,
    required this.brouillon,
    required this.echantillonValide,
    required this.enregistrementEnCours,
    required this.positionEnCoursDeChargement,
    required this.echecPosition,
    required this.onChangerNumero,
    required this.onChangerProducteur,
    required this.onChangerVariete,
    required this.onChangerRegion,
    required this.onChangerDateRecolte,
    required this.onPositionActuelle,
    required this.onValider,
    required this.onModifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 20, color: AppColors.vertOliveFonce),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.carteInformationsEchantillonTitre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ),
              if (mode == ModeCarteEchantillon.consultation)
                TextButton.icon(
                  onPressed: onModifier,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.vertOlive),
                  label: Text(l10n.modifierBouton, style: AppTextStyles.lienAction),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (mode == ModeCarteEchantillon.formulaire)
            _Formulaire(
              brouillon: brouillon,
              enregistrementEnCours: enregistrementEnCours,
              positionEnCoursDeChargement: positionEnCoursDeChargement,
              echecPosition: echecPosition,
              onChangerNumero: onChangerNumero,
              onChangerProducteur: onChangerProducteur,
              onChangerVariete: onChangerVariete,
              onChangerRegion: onChangerRegion,
              onChangerDateRecolte: onChangerDateRecolte,
              onPositionActuelle: onPositionActuelle,
              onValider: onValider,
            )
          else if (echantillonValide != null)
            _Consultation(echantillon: echantillonValide!),
        ],
      ),
    );
  }
}

class _Formulaire extends StatelessWidget {
  final NouvelEchantillonEntity brouillon;
  final bool enregistrementEnCours;
  final bool positionEnCoursDeChargement;
  final String? echecPosition;
  final ValueChanged<String> onChangerNumero;
  final ValueChanged<String> onChangerProducteur;
  final ValueChanged<String> onChangerVariete;
  final ValueChanged<String> onChangerRegion;
  final ValueChanged<DateTime> onChangerDateRecolte;
  final VoidCallback onPositionActuelle;
  final VoidCallback onValider;

  const _Formulaire({
    required this.brouillon,
    required this.enregistrementEnCours,
    required this.positionEnCoursDeChargement,
    required this.echecPosition,
    required this.onChangerNumero,
    required this.onChangerProducteur,
    required this.onChangerVariete,
    required this.onChangerRegion,
    required this.onChangerDateRecolte,
    required this.onPositionActuelle,
    required this.onValider,
  });

  String _messageErreurPosition(BuildContext context, String code) {
    final l10n = context.l10n;
    return switch (code) {
      'service' => l10n.erreurLocalisationService,
      'permission' => l10n.erreurLocalisationPermission,
      _ => l10n.erreurLocalisationGenerique,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChampTexte(
          libelle: l10n.champIdEchantillon,
          valeurInitiale: brouillon.numero,
          onChange: onChangerNumero,
        ),
        const SizedBox(height: 12),
        _ChampTexte(
          libelle: l10n.champProducteur,
          valeurInitiale: brouillon.producteur,
          onChange: onChangerProducteur,
        ),
        const SizedBox(height: 12),
        _ChampTexte(
          libelle: l10n.champVariete,
          valeurInitiale: brouillon.variete,
          onChange: onChangerVariete,
        ),
        const SizedBox(height: 12),
        _ChampTexte(
          libelle: l10n.champRegion,
          valeurInitiale: brouillon.region,
          onChange: onChangerRegion,
        ),
        const SizedBox(height: 12),
        _ChampDate(
          libelle: l10n.champDateRecolte,
          date: brouillon.dateRecolte,
          onChange: onChangerDateRecolte,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.champGps, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    brouillon.aCoordonneesGps
                        ? '${brouillon.latitude!.toStringAsFixed(4)}° N, ${brouillon.longitude!.toStringAsFixed(4)}° W'
                        : l10n.gpsNonRenseigne,
                    style: AppTextStyles.champTexte,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: positionEnCoursDeChargement ? null : onPositionActuelle,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.vertOlive),
              icon: positionEnCoursDeChargement
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                    )
                  : const Icon(Icons.my_location, size: 16),
              label: Text(l10n.positionActuelleBouton),
            ),
          ],
        ),
        if (echecPosition != null) ...[
          const SizedBox(height: 8),
          Text(_messageErreurPosition(context, echecPosition!), style: AppTextStyles.erreurChamp),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enregistrementEnCours ? null : onValider,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vertOlive,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: enregistrementEnCours
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                  )
                : Text(l10n.validerInformationsBouton, style: AppTextStyles.boutonPrincipal),
          ),
        ),
      ],
    );
  }
}

class _ChampTexte extends StatelessWidget {
  final String libelle;
  final String valeurInitiale;
  final ValueChanged<String> onChange;

  const _ChampTexte({required this.libelle, required this.valeurInitiale, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valeurInitiale,
      onChanged: onChange,
      style: AppTextStyles.champTexte,
      decoration: InputDecoration(
        labelText: libelle,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ChampDate extends StatelessWidget {
  final String libelle;
  final DateTime? date;
  final ValueChanged<DateTime> onChange;

  const _ChampDate({required this.libelle, required this.date, required this.onChange});

  Future<void> _choisirDate(BuildContext context) async {
    final l10n = context.l10n;
    final choisie = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: l10n.champDateRecolte,
    );
    if (choisie != null) onChange(choisie);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texte = date != null ? DateFormat.yMd(l10n.localeName).format(date!) : l10n.selectionnerDate;

    return InkWell(
      onTap: () => _choisirDate(context),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: libelle,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(texte, style: AppTextStyles.champTexte),
      ),
    );
  }
}

class _Consultation extends StatelessWidget {
  final NouvelEchantillonEntity echantillon;

  const _Consultation({required this.echantillon});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateRecolte = echantillon.dateRecolte != null
        ? DateFormat.yMd(l10n.localeName).format(echantillon.dateRecolte!)
        : l10n.gpsNonRenseigne;
    final gps = echantillon.aCoordonneesGps
        ? '${echantillon.latitude!.toStringAsFixed(4)}°, ${echantillon.longitude!.toStringAsFixed(4)}°'
        : l10n.gpsNonRenseigne;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Champ(icone: Icons.tag, libelle: l10n.champIdEchantillon, valeur: echantillon.numero),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Champ(icone: Icons.public, libelle: l10n.champRegion, valeur: echantillon.region),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Champ(icone: Icons.factory_outlined, libelle: l10n.champProducteur, valeur: echantillon.producteur),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Champ(icone: Icons.event_outlined, libelle: l10n.champDateRecolte, valeur: dateRecolte),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Champ(icone: Icons.eco_outlined, libelle: l10n.champVariete, valeur: echantillon.variete),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Champ(icone: Icons.location_on_outlined, libelle: l10n.champGps, valeur: gps),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.evooFond,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: AppColors.succes),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.metadonneesCompletesTitre,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.succes),
                    ),
                    Text(
                      l10n.metadonneesCompletesTexte,
                      style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Champ extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final String valeur;

  const _Champ({required this.icone, required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: AppColors.grisMoyen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                valeur.isEmpty ? '—' : valeur,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
