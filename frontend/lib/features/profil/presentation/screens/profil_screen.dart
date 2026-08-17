import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/package_info_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/storage/espace_stockage_provider.dart';
import '../../../../core/storage/espace_stockage_service.dart';
import '../../../../core/sync/synchronisation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../authentification/domain/usecases/logout_usecase.dart';
import '../../../alertes/presentation/providers/alertes_provider.dart';
import '../../../configuration/domain/entities/configuration_entity.dart';
import '../../../configuration/presentation/providers/configuration_provider.dart';
import '../../../parametres/presentation/providers/locale_provider.dart';
import '../../../parametres/presentation/providers/theme_mode_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/profil_provider.dart';
import '../providers/sessions_provider.dart';
import '../widgets/carte_identite.dart';
import '../widgets/ligne_parametre.dart';

/// Écran "Mon Profil" (design/6-profil.png), accessible depuis l'onglet
/// Paramètres de la coquille de navigation. Toutes les données viennent de
/// l'API (profilProvider -> GET /api/utilisateurs/moi/) — aucune valeur en
/// dur. Tous les sous-écrans (>) s'ouvrent DANS cet onglet (voir
/// core/navigation/app_router.dart), la barre du bas reste visible.
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

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

  Future<void> _choisirTheme(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final modeActif = ref.read(themeModeProvider);

    Widget option(ThemeMode mode, String libelle) {
      return ListTile(
        title: Text(libelle),
        trailing: modeActif == mode ? const Icon(Icons.check_circle, color: AppColors.vertOlive) : null,
        onTap: () {
          ref.read(themeModeProvider.notifier).changerModeTheme(mode);
          Navigator.of(context).pop();
        },
      );
    }

    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(ThemeMode.light, l10n.themeClair),
            option(ThemeMode.dark, l10n.themeSombreLabel),
            option(ThemeMode.system, l10n.themeSysteme),
          ],
        ),
      ),
    );
  }

  String _libelleTheme(ThemeMode mode, AppLocalizations l10n) => switch (mode) {
        ThemeMode.light => l10n.themeClair,
        ThemeMode.dark => l10n.themeSombreLabel,
        ThemeMode.system => l10n.themeSysteme,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(profilProvider);
    final alertesState = ref.watch(alertesProvider);
    final alertesNonLues = (alertesState.alertes ?? const []).where((a) => !a.estResolue).length;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.evooFond, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, color: AppColors.vertOliveFonce, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.monProfilTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
                        Text(
                          l10n.monProfilSousTitre,
                          style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/accueil/alertes'),
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.grisFonce),
                      ),
                      if (alertesNonLues > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.succes, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _corps(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, ProfilState state) {
    final l10n = context.l10n;

    if (state.profil == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.profil == null && state.echec != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.grisMoyen),
              const SizedBox(height: 16),
              Text(
                state.echec!.messageLocalise(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                onPressed: () => ref.read(profilProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    if (state.profil == null) return const SizedBox.shrink();
    final profil = state.profil!;

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(profilProvider.notifier).charger(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          CarteIdentite(
            profil: profil,
            onChangerPhoto: () => _changerPhoto(context, ref),
            televersementEnCours: state.enregistrementEnCours,
          ),
          const SizedBox(height: 20),
          _TitreSection(l10n.compteSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LigneParametre(
                  icone: Icons.person_outline,
                  titre: l10n.informationsPersonnellesTitre,
                  sousTitre: l10n.informationsPersonnellesSousTitre,
                  onTap: () => context.push('/parametres/informations-personnelles'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.shield_outlined,
                  titre: l10n.securiteTitre,
                  sousTitre: l10n.securiteSousTitre,
                  onTap: () => context.push('/parametres/securite'),
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
                    onTap: () => context.push('/parametres/sessions'),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _TitreSection(l10n.preferencesSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LigneParametre(
                  icone: Icons.science_outlined,
                  titre: l10n.preferencesAnalyseTitre,
                  sousTitre: l10n.preferencesAnalyseSousTitre,
                  onTap: () => context.push('/parametres/preferences-analyse'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                _LigneNotifications(l10n: l10n),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                Consumer(builder: (context, ref, _) {
                  final locale = ref.watch(localeProvider);
                  return LigneParametre(
                    icone: Icons.language,
                    titre: l10n.langueSectionTitre,
                    fin: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        locale.languageCode == 'fr' ? l10n.langueFrancais : l10n.langueAnglais,
                        style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                      ),
                    ),
                    onTap: () => _choisirLangue(context, ref),
                  );
                }),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                Consumer(builder: (context, ref, _) {
                  final mode = ref.watch(themeModeProvider);
                  return LigneParametre(
                    icone: Icons.dark_mode_outlined,
                    titre: l10n.themeTitre,
                    fin: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        _libelleTheme(mode, l10n),
                        style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                      ),
                    ),
                    onTap: () => _choisirTheme(context, ref),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _TitreSection(l10n.donneesSyncSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _LigneSynchronisationCloud(),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                Consumer(builder: (context, ref, _) {
                  final enAttente = ref.watch(elementsEnAttenteSyncProvider).valueOrNull ?? 0;
                  return LigneParametre(
                    icone: Icons.cloud_upload_outlined,
                    titre: l10n.fileAttenteSyncTitre,
                    sousTitre: l10n.fileAttenteSyncSousTitre,
                    fin: enAttente == 0
                        ? null
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orangeFond,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$enAttente',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orangeIcone,
                              ),
                            ),
                          ),
                    onTap: () => context.push('/synchronisation/file-attente'),
                  );
                }),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.storage_outlined,
                  titre: l10n.gestionDonneesTitre,
                  sousTitre: l10n.gestionDonneesSousTitre,
                  onTap: () => context.push('/parametres/gestion-donnees'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                const _LigneEspaceStockage(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _TitreSection(l10n.aProposSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _LigneAPropos(),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.help_outline,
                  titre: l10n.centreAideTitre,
                  sousTitre: l10n.centreAideSousTitre,
                  onTap: () => context.push('/parametres/aide'),
                ),
                const Divider(height: 1, color: AppColors.grisLigne, indent: 16, endIndent: 16),
                LigneParametre(
                  icone: Icons.description_outlined,
                  titre: l10n.mentionsLegalesTitre,
                  onTap: () => context.push('/parametres/mentions-legales'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
}

class _TitreSection extends StatelessWidget {
  final String texte;

  const _TitreSection(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
    );
  }
}

class _LigneNotifications extends ConsumerWidget {
  final AppLocalizations l10n;

  const _LigneNotifications({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(configurationProvider);
    final configuration = configState.configuration;

    return LigneParametre(
      icone: Icons.notifications_outlined,
      titre: l10n.notificationsPreferenceTitre,
      sousTitre: l10n.notificationsPreferenceSousTitre,
      fin: Switch(
        value: configuration?.notificationsActives ?? false,
        activeThumbColor: AppColors.vertOlive,
        onChanged: configuration == null
            ? null
            : (valeur) async {
                final l10nLocal = context.l10n;
                final succes = await ref.read(configurationProvider.notifier).modifier(
                      ConfigurationEntity(
                        notificationsActives: valeur,
                        seuilConformiteAcidite: configuration.seuilConformiteAcidite,
                        seuilConformitePeroxyde: configuration.seuilConformitePeroxyde,
                        seuilAciditeEvoo: configuration.seuilAciditeEvoo,
                        seuilAciditeVoo: configuration.seuilAciditeVoo,
                      ),
                    );
                if (!succes && context.mounted) {
                  final echec = ref.read(configurationProvider).echec;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(echec?.messageLocalise(context) ?? l10nLocal.erreurServeur),
                  ));
                }
              },
      ),
    );
  }
}

class _LigneSynchronisationCloud extends ConsumerWidget {
  const _LigneSynchronisationCloud();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(syncActiveeProvider);
    final derniereSync = ref.watch(derniereSynchronisationProvider).valueOrNull;

    final sousTitre = !active
        ? l10n.syncDesactiveeLabel
        : (derniereSync == null
            ? l10n.syncJamaisLabel
            : l10n.derniereSyncLabel(DateFormat.yMd(l10n.localeName).add_Hm().format(derniereSync)));

    return LigneParametre(
      icone: Icons.cloud_outlined,
      titre: l10n.synchronisationCloudTitre,
      sousTitre: sousTitre,
      fin: Switch(
        value: active,
        activeThumbColor: AppColors.vertOlive,
        onChanged: (valeur) => ref.read(syncActiveeProvider.notifier).definir(valeur),
      ),
    );
  }
}

class _LigneEspaceStockage extends ConsumerWidget {
  const _LigneEspaceStockage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final espace = ref.watch(espaceStockageProvider);

    return LigneParametre(
      icone: Icons.pie_chart_outline,
      titre: l10n.espaceStockageTitre,
      fin: espace.when(
        data: (octets) => Text(
          formaterTailleOctets(octets),
          style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
        ),
        loading: () => const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
        ),
        error: (_, _) => const Text('—', style: AppTextStyles.sousTexteBienvenue),
      ),
    );
  }
}

class _LigneAPropos extends ConsumerWidget {
  const _LigneAPropos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final infos = ref.watch(packageInfoProvider);

    return LigneParametre(
      icone: Icons.info_outline,
      titre: l10n.aProposOliveIQTitre,
      sousTitre: infos.when(
        data: (info) => l10n.versionBuildLabel(info.version, info.buildNumber),
        loading: () => null,
        error: (_, _) => null,
      ),
      onTap: () => context.push('/parametres/a-propos'),
    );
  }
}
