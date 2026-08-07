import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/storage/espace_stockage_provider.dart';
import '../../../../core/storage/espace_stockage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../historique/domain/usecases/declencher_export_usecase.dart';

const _espaceStockageService = EspaceStockageService();

/// Sous-écran "Gestion des données" — exporter ses données (réutilise le
/// mécanisme d'export déjà en place pour l'Historique, POST
/// /api/analyses/export/) et vider le cache local de l'appareil. Ne touche
/// jamais à la base Drift : les analyses en attente de synchronisation ne
/// sont jamais supprimées par cet écran.
class GestionDonneesScreen extends ConsumerStatefulWidget {
  const GestionDonneesScreen({super.key});

  @override
  ConsumerState<GestionDonneesScreen> createState() => _GestionDonneesScreenState();
}

class _GestionDonneesScreenState extends ConsumerState<GestionDonneesScreen> {
  bool _exportEnCours = false;
  bool _viderCacheEnCours = false;

  Future<void> _exporter(String format) async {
    setState(() => _exportEnCours = true);
    final resultat = await sl<DeclencherExportUseCase>()(format);
    if (!mounted) return;
    setState(() => _exportEnCours = false);
    final l10n = context.l10n;
    resultat.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context)))),
      (_) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.exportLanceMessage))),
    );
  }

  Future<void> _confirmerExport() async {
    final format = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final format in const ['PDF', 'CSV', 'XLSX'])
              ListTile(title: Text(format), onTap: () => Navigator.of(sheetContext).pop(format)),
          ],
        ),
      ),
    );
    if (format != null) await _exporter(format);
  }

  Future<void> _viderCache() async {
    final l10n = context.l10n;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.viderCacheConfirmationTitre),
        content: Text(l10n.viderCacheConfirmationTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.annulerBouton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirmerBouton),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _viderCacheEnCours = true);
    await _espaceStockageService.viderCache();
    if (!mounted) return;
    setState(() => _viderCacheEnCours = false);
    ref.invalidate(espaceStockageProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cacheVideMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final espace = ref.watch(espaceStockageProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.gestionDonneesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CarteStylisee(
            child: Row(
              children: [
                const Icon(Icons.pie_chart_outline, color: AppColors.vertOliveFonce),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.espaceStockageTitre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      espace.when(
                        data: (octets) => Text(formaterTailleOctets(octets), style: AppTextStyles.sousTexteBienvenue),
                        loading: () => Text('…', style: AppTextStyles.sousTexteBienvenue),
                        error: (_, _) => Text('—', style: AppTextStyles.sousTexteBienvenue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _exportEnCours ? null : _confirmerExport,
              icon: _exportEnCours
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
                    )
                  : const Icon(Icons.ios_share, size: 18),
              label: Text(l10n.exporterMesDonneesBouton),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.erreur,
                side: const BorderSide(color: AppColors.erreur),
              ),
              onPressed: _viderCacheEnCours ? null : _viderCache,
              icon: _viderCacheEnCours
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.erreur),
                    )
                  : const Icon(Icons.delete_outline, size: 18),
              label: Text(l10n.viderCacheBouton),
            ),
          ),
        ],
      ),
    );
  }
}
