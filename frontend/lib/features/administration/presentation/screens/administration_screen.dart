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
import '../../../../core/config/package_info_provider.dart';
import '../../../parametres/presentation/providers/locale_provider.dart';
import '../../../profil/presentation/providers/profil_provider.dart';
import '../../../profil/presentation/providers/sessions_provider.dart';
import '../../../profil/presentation/widgets/carte_identite.dart';
import '../../../profil/presentation/widgets/ligne_parametre.dart';
import '../widgets/entete_ecran_admin.dart';

/// Onglet "Administration" — identité de l'administrateur affichée en tête
/// (pas de sous-écran "Mon profil" séparé, pour éviter un tap supplémentaire
/// sur une info consultée à chaque visite de cet onglet), puis dans l'ordre :
/// Compte (informations personnelles / sécurité / sessions actives — mêmes
/// écrans que ProfilScreen, réutilisés tels quels sous /admin/administration/...
/// puisqu'aucun n'effectue de navigation interne), journal d'audit / gestion
/// des données / préférences d'analyse (réutilise PreferencesAnalyseScreen,
/// déjà admin-only côté API) / langue, À propos (à propos d'Olive IQ / centre
/// d'aide / mentions légales), et enfin la déconnexion. Pas de bascule de
/// thème ici : le mode sombre existe déjà dans AppTheme mais la plupart des
/// écrans lisent encore AppColors en dur plutôt que Theme.of(context), donc
/// l'exposer ne changerait rien de visible — voir le commentaire de
/// app_theme.dart pour ce chantier différé.
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
        title: EnTeteEcranAdmin(
          icone: Icons.admin_panel_settings_outlined,
          couleur: AppColors.bleuIcone,
          fond: AppColors.bleuFond,
          titre: l10n.administrationTitre,
          sousTitre: l10n.administrationSousTitreEcran,
        ),
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
          const SizedBox(height: 24),
          Text(
            l10n.compteSectionTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LigneParametre(
                  icone: Icons.person_outline,
                  titre: l10n.informationsPersonnellesTitre,
                  sousTitre: l10n.informationsPersonnellesSousTitre,
                  onTap: () => context.push('/admin/administration/informations-personnelles'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.shield_outlined,
                  titre: l10n.securiteTitre,
                  sousTitre: l10n.securiteSousTitre,
                  onTap: () => context.push('/admin/administration/securite'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                Consumer(builder: (context, ref, _) {
                  final sessions = ref.watch(sessionsProvider).sessions;
                  return LigneParametre(
                    icone: Icons.devices_outlined,
                    titre: l10n.sessionsActivesTitre,
                    sousTitre: l10n.sessionsActivesSousTitre,
                    fin: sessions == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              l10n.sessionsActivesCompteur(sessions.length),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.vertOlive),
                            ),
                          ),
                    onTap: () => context.push('/admin/administration/sessions'),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          Text(
            l10n.aProposSectionTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Consumer(builder: (context, ref, _) {
                  final infos = ref.watch(packageInfoProvider);
                  return LigneParametre(
                    icone: Icons.info_outline,
                    titre: l10n.aProposOliveIQTitre,
                    sousTitre: infos.when(
                      data: (info) => l10n.versionBuildLabel(info.version, info.buildNumber),
                      loading: () => null,
                      error: (_, _) => null,
                    ),
                    onTap: () => context.push('/admin/administration/a-propos'),
                  );
                }),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.help_outline,
                  titre: l10n.centreAideTitre,
                  sousTitre: l10n.centreAideSousTitre,
                  onTap: () => context.push('/admin/administration/aide'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.description_outlined,
                  titre: l10n.mentionsLegalesTitre,
                  onTap: () => context.push('/admin/administration/mentions-legales'),
                ),
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
