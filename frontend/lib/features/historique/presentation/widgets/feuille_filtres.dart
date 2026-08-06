import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/analyse_historique_entity.dart';

/// Feuille "Plus de filtres" : qualité, variété, région, période. Renvoie
/// les [FiltresHistorique] choisis à la fermeture, appliqués par l'appelant
/// via HistoriqueNotifier.appliquerFiltres — jamais de filtrage local ici.
Future<void> afficherFeuilleFiltres(
  BuildContext context, {
  required FiltresHistorique filtresActuels,
  required ValueChanged<FiltresHistorique> onAppliquer,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.blanc,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _FeuilleFiltres(filtresActuels: filtresActuels, onAppliquer: onAppliquer),
  );
}

class _FeuilleFiltres extends StatefulWidget {
  final FiltresHistorique filtresActuels;
  final ValueChanged<FiltresHistorique> onAppliquer;

  const _FeuilleFiltres({required this.filtresActuels, required this.onAppliquer});

  @override
  State<_FeuilleFiltres> createState() => _FeuilleFiltresState();
}

class _FeuilleFiltresState extends State<_FeuilleFiltres> {
  String? _qualite;
  late final TextEditingController _varieteControleur;
  late final TextEditingController _regionControleur;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    _qualite = widget.filtresActuels.qualite;
    _varieteControleur = TextEditingController(text: widget.filtresActuels.variete ?? '');
    _regionControleur = TextEditingController(text: widget.filtresActuels.region ?? '');
    _dateDebut = widget.filtresActuels.dateDebut;
    _dateFin = widget.filtresActuels.dateFin;
  }

  @override
  void dispose() {
    _varieteControleur.dispose();
    _regionControleur.dispose();
    super.dispose();
  }

  Future<void> _choisirDate({required bool debut}) async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: (debut ? _dateDebut : _dateFin) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (choisie == null) return;
    setState(() {
      if (debut) {
        _dateDebut = choisie;
      } else {
        _dateFin = choisie;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.filtresTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Text(l10n.filtreQualite, style: AppTextStyles.sousTexteBienvenue),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _OptionQualite(code: null, libelle: l10n.filtreTout, actif: _qualite, onSelect: (v) => setState(() => _qualite = v)),
                _OptionQualite(code: 'evoo', libelle: l10n.categorieEvooCourt, actif: _qualite, onSelect: (v) => setState(() => _qualite = v)),
                _OptionQualite(code: 'voo', libelle: l10n.categorieVooCourt, actif: _qualite, onSelect: (v) => setState(() => _qualite = v)),
                _OptionQualite(code: 'lampante', libelle: l10n.categorieLampanteCourt, actif: _qualite, onSelect: (v) => setState(() => _qualite = v)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _varieteControleur,
              decoration: InputDecoration(
                labelText: l10n.champVariete,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regionControleur,
              decoration: InputDecoration(
                labelText: l10n.champRegion,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _choisirDate(debut: true),
                    child: Text(_dateDebut != null
                        ? formatDate.format(_dateDebut!)
                        : l10n.dateDebutLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _choisirDate(debut: false),
                    child: Text(_dateFin != null ? formatDate.format(_dateFin!) : l10n.dateFinLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _qualite = null;
                        _varieteControleur.clear();
                        _regionControleur.clear();
                        _dateDebut = null;
                        _dateFin = null;
                      });
                    },
                    child: Text(l10n.reinitialiserBouton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                    onPressed: () {
                      widget.onAppliquer(FiltresHistorique(
                        recherche: widget.filtresActuels.recherche,
                        qualite: _qualite,
                        variete: _varieteControleur.text.isEmpty ? null : _varieteControleur.text,
                        region: _regionControleur.text.isEmpty ? null : _regionControleur.text,
                        dateDebut: _dateDebut,
                        dateFin: _dateFin,
                      ));
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.appliquerBouton, style: AppTextStyles.boutonPrincipal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionQualite extends StatelessWidget {
  final String? code;
  final String libelle;
  final String? actif;
  final ValueChanged<String?> onSelect;

  const _OptionQualite({required this.code, required this.libelle, required this.actif, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final selectionne = actif == code;
    return ChoiceChip(
      label: Text(libelle),
      selected: selectionne,
      onSelected: (_) => onSelect(code),
      selectedColor: AppColors.vertOlive,
      labelStyle: TextStyle(color: selectionne ? AppColors.blanc : AppColors.grisFonce, fontSize: 13),
      backgroundColor: AppColors.fond,
    );
  }
}
