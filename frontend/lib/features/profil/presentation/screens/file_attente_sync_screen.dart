import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/sync/element_file_attente.dart';
import '../../../../core/sync/synchronisation_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../../core/widgets/entete_ecran.dart';

/// Écran "File d'attente de synchronisation" (cahier des charges, Partie A,
/// section 5) : liste les échantillons/spectres/résultats pas encore
/// confirmés par le serveur, avec leur état et l'erreur éventuelle, et
/// permet de relancer manuellement — accessible depuis Paramètres et depuis
/// l'indicateur global (voir core/sync/indicateur_etat_sync.dart). Route
/// racine (hors des deux coquilles de navigation) pour rester atteignable
/// aussi bien depuis l'espace utilisateur que l'espace admin.
class FileAttenteSyncScreen extends ConsumerStatefulWidget {
  const FileAttenteSyncScreen({super.key});

  @override
  ConsumerState<FileAttenteSyncScreen> createState() => _FileAttenteSyncScreenState();
}

class _FileAttenteSyncScreenState extends ConsumerState<FileAttenteSyncScreen> {
  bool _relanceEnCours = false;

  Future<void> _relancer() async {
    setState(() => _relanceEnCours = true);
    await sl<SynchronisationService>().synchroniser(forcer: true);
    if (mounted) setState(() => _relanceEnCours = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final elements = ref.watch(elementsFileAttenteProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: EnTeteEcran(
          icone: Icons.cloud_upload_outlined,
          couleur: AppColors.orangeIcone,
          fond: AppColors.orangeFond,
          titre: l10n.fileAttenteSyncTitre,
          sousTitre: l10n.fileAttenteSyncSousTitre,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                  onPressed: _relanceEnCours || elements.isEmpty ? null : _relancer,
                  icon: _relanceEnCours
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                        )
                      : const Icon(Icons.sync, size: 18, color: AppColors.blanc),
                  label: Text(
                    l10n.relancerSynchronisationBouton,
                    style: AppTextStyles.boutonPrincipal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: elements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_done_outlined, size: 48, color: AppColors.succes),
                            const SizedBox(height: 12),
                            Text(
                              l10n.fileAttenteVideMessage,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.sousTexteBienvenue,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: elements.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _CarteElement(element: elements[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteElement extends StatelessWidget {
  final ElementFileAttente element;

  const _CarteElement({required this.element});

  IconData get _icone {
    switch (element.type) {
      case TypeElementFileAttente.echantillon:
        return Icons.eco_outlined;
      case TypeElementFileAttente.spectre:
        return Icons.show_chart;
      case TypeElementFileAttente.resultat:
        return Icons.science_outlined;
    }
  }

  String _typeLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (element.type) {
      case TypeElementFileAttente.echantillon:
        return l10n.typeElementEchantillon;
      case TypeElementFileAttente.spectre:
        return l10n.typeElementSpectre;
      case TypeElementFileAttente.resultat:
        return l10n.typeElementResultat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatHeure = DateFormat.Hm(l10n.localeName);
    final couleur = element.enErreur ? AppColors.erreur : AppColors.orangeIcone;
    final fond = element.enErreur ? AppColors.lampanteFond : AppColors.orangeFond;

    return CarteStylisee(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
            child: Icon(_icone, size: 18, color: couleur),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_typeLabel(context)} · ${element.libelle}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grisFonce,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formatHeure.format(element.dateCreationLocale),
                      style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  element.enErreur
                      ? l10n.statutErreurSyncAvecTentatives(element.nombreTentatives)
                      : l10n.statutEnAttenteSync,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: couleur),
                ),
                if (element.enErreur && element.messageErreur != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    element.messageErreur!,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
