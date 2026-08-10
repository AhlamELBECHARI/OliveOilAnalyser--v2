import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/demande_export_entity.dart';

/// Feuille "Exporter" : quoi exporter, quelles analyses (filtres actifs ou
/// sélection manuelle) et dans quel format. N'effectue aucun appel réseau
/// elle-même — elle renvoie le choix à l'appelant (HistoriqueScreen), qui
/// déclenche soit l'export direct, soit le mode sélection sur la liste.
Future<void> afficherFeuilleExport(
  BuildContext context, {
  required int totalAnalysesFiltrees,
  required ValueChanged<DemandeExportEntity> onExporterParFiltres,
  required void Function({required ContenuExport contenu, required String format})
      onDemarrerSelectionManuelle,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.blanc,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _FeuilleExport(
      totalAnalysesFiltrees: totalAnalysesFiltrees,
      onExporterParFiltres: onExporterParFiltres,
      onDemarrerSelectionManuelle: onDemarrerSelectionManuelle,
    ),
  );
}

class _FeuilleExport extends StatefulWidget {
  final int totalAnalysesFiltrees;
  final ValueChanged<DemandeExportEntity> onExporterParFiltres;
  final void Function({required ContenuExport contenu, required String format})
      onDemarrerSelectionManuelle;

  const _FeuilleExport({
    required this.totalAnalysesFiltrees,
    required this.onExporterParFiltres,
    required this.onDemarrerSelectionManuelle,
  });

  @override
  State<_FeuilleExport> createState() => _FeuilleExportState();
}

class _FeuilleExportState extends State<_FeuilleExport> {
  ContenuExport _contenu = ContenuExport.resultats;
  bool _selectionManuelle = false;
  String _format = 'CSV';

  void _choisirContenu(ContenuExport contenu) {
    setState(() {
      _contenu = contenu;
      // Le PDF n'a de sens que pour les résultats (voir
      // analyses.export._generer_pdf côté backend) : jamais proposé sinon.
      if (contenu != ContenuExport.resultats && _format == 'PDF') {
        _format = 'CSV';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.exportTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Text(l10n.exportContenuLabel, style: AppTextStyles.sousTexteBienvenue),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Puce(
                  libelle: l10n.exportContenuResultats,
                  selectionne: _contenu == ContenuExport.resultats,
                  onTap: () => _choisirContenu(ContenuExport.resultats),
                ),
                _Puce(
                  libelle: l10n.exportContenuSpectres,
                  selectionne: _contenu == ContenuExport.spectres,
                  onTap: () => _choisirContenu(ContenuExport.spectres),
                ),
                _Puce(
                  libelle: l10n.exportContenuLesDeux,
                  selectionne: _contenu == ContenuExport.lesDeux,
                  onTap: () => _choisirContenu(ContenuExport.lesDeux),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.exportQuellesAnalysesLabel, style: AppTextStyles.sousTexteBienvenue),
            RadioGroup<bool>(
              groupValue: _selectionManuelle,
              onChanged: (v) => setState(() => _selectionManuelle = v!),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    activeColor: AppColors.vertOlive,
                    title: Text(
                      l10n.exportToutesFiltresLabel(widget.totalAnalysesFiltrees),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    activeColor: AppColors.vertOlive,
                    title: Text(l10n.exportSelectionManuelleLabel, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.exportFormatLabel, style: AppTextStyles.sousTexteBienvenue),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Puce(libelle: 'CSV', selectionne: _format == 'CSV', onTap: () => setState(() => _format = 'CSV')),
                _Puce(libelle: 'XLSX', selectionne: _format == 'XLSX', onTap: () => setState(() => _format = 'XLSX')),
                if (_contenu == ContenuExport.resultats)
                  _Puce(libelle: 'PDF', selectionne: _format == 'PDF', onTap: () => setState(() => _format = 'PDF')),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vertOlive,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_selectionManuelle) {
                    widget.onDemarrerSelectionManuelle(contenu: _contenu, format: _format);
                  } else {
                    widget.onExporterParFiltres(
                      DemandeExportEntity(contenu: _contenu, format: _format),
                    );
                  }
                },
                child: Text(
                  _selectionManuelle ? l10n.choisirAnalysesBouton : l10n.exporterBouton,
                  style: AppTextStyles.boutonPrincipal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Puce extends StatelessWidget {
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  const _Puce({required this.libelle, required this.selectionne, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(libelle),
      selected: selectionne,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.vertOlive,
      labelStyle: TextStyle(color: selectionne ? AppColors.blanc : AppColors.grisFonce, fontSize: 13),
      backgroundColor: AppColors.fond,
    );
  }
}
