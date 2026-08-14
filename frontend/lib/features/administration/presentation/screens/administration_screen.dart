import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../authentification/domain/usecases/logout_usecase.dart';
import '../../../parametres/presentation/providers/locale_provider.dart';
import '../../../profil/presentation/providers/profil_provider.dart';
import '../../../profil/presentation/widgets/carte_identite.dart';
import '../../../profil/presentation/widgets/ligne_parametre.dart';

/// Onglet "Administration" — identité de l'administrateur affichée en tête
/// (pas de sous-écran "Mon profil" séparé, pour éviter un tap supplémentaire
/// sur une info consultée à chaque visite de cet onglet), puis la liste
/// journal d'audit / gestion des données / préférences d'analyse (réutilise
/// PreferencesAnalyseScreen, déjà admin-only côté API) / langue, et enfin la
/// déconnexion. Pas de bascule de thème ici : le mode sombre existe déjà
/// dans AppTheme mais la plupart des écrans lisent encore AppColors en dur
/// plutôt que Theme.of(context), donc l'exposer ne changerait rien de
/// visible — voir le commentaire de app_theme.dart pour ce chantier différé.
class AdministrationScreen extends ConsumerWidget {
  const AdministrationScreen({super.key});

  Future<void> _changerPhoto(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final fichier = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (fichier == null) return;
    if (!context.mounted) return;

    final resultat = await ref.read(profilProvider.notifier).televerserPhoto(fichier);
    if (!context.mounted) return;
    resultat.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context)))),
      (_) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.photoProfilMiseAJourMessage))),
    );
  }

  Future<void> _seDeconnecter(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.seDeconnecterConfirmationTitre),
        content: Text(l10n.seDeconnecterConfirmationTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.annulerBouton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.seDeconnecter, style: const TextStyle(color: AppColors.erreur)),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    await sl<LogoutUseCase>()(const NoParams());
    if (context.mounted) context.go('/login');
  }

  Future<void> _choisirLangue(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final localeActive = ref.read(localeProvider);
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.langueFrancais),
              trailing: localeActive.languageCode == 'fr'
                  ? const Icon(Icons.check_circle, color: AppColors.vertOlive)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).changerLocale(const Locale('fr'));
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              title: Text(l10n.langueAnglais),
              trailing: localeActive.languageCode == 'en'
                  ? const Icon(Icons.check_circle, color: AppColors.vertOlive)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).changerLocale(const Locale('en'));
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.administrationTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.monProfilTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          _carteIdentite(context, ref, state),
          const SizedBox(height: 16),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LigneParametre(
                  icone: Icons.history,
                  titre: l10n.journalAuditTitre,
                  sousTitre: l10n.journalAuditSousTitre,
                  onTap: () => context.push('/admin/administration/journal-audit'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.storage_outlined,
                  titre: l10n.gestionDonneesAdminTitre,
                  sousTitre: l10n.gestionDonneesSousTitreAdmin,
                  onTap: () => context.push('/admin/administration/gestion-donnees'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.tune,
                  titre: l10n.preferencesAnalyseTitre,
                  sousTitre: l10n.configurationSousTitreAdmin,
                  onTap: () => context.push('/admin/administration/configuration'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                Consumer(builder: (context, ref, _) {
                  final locale = ref.watch(localeProvider);
                  return LigneParametre(
                    icone: Icons.language,
                    titre: l10n.langueSectionTitre,
                    fin: Text(
                      locale.languageCode == 'fr' ? l10n.langueFrancais : l10n.langueAnglais,
                      style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                    ),
                    onTap: () => _choisirLangue(context, ref),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.erreur, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _seDeconnecter(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.erreur, size: 18),
              label: Text(
                l10n.seDeconnecter,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.erreur),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteIdentite(BuildContext context, WidgetRef ref, ProfilState state) {
    if (state.profil == null && state.enChargement) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.vertOlive)),
      );
    }
    if (state.profil == null && state.echec != null) {
      return Center(
        child: Text(state.echec!.messageLocalise(context), style: AppTextStyles.sousTexteBienvenue),
      );
    }
    if (state.profil == null) return const SizedBox.shrink();

    return CarteIdentite(
      profil: state.profil!,
      onChangerPhoto: () => _changerPhoto(context, ref),
      televersementEnCours: state.enregistrementEnCours,
    );
  }
}
