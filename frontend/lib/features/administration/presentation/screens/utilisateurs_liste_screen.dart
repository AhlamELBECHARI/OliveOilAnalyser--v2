import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/utilisateur_admin_entity.dart';
import '../providers/utilisateurs_liste_provider.dart';
import '../widgets/feuille_creer_utilisateur.dart';

/// Liste des utilisateurs (recherche + filtres), alimentée par
/// GET /api/admin/utilisateurs/. Chaque ligne ouvre la fiche détaillée
/// (voir UtilisateurDetailScreen) pour les actions de gestion.
class UtilisateursListeScreen extends ConsumerStatefulWidget {
  const UtilisateursListeScreen({super.key});

  @override
  ConsumerState<UtilisateursListeScreen> createState() => _UtilisateursListeScreenState();
}

class _UtilisateursListeScreenState extends ConsumerState<UtilisateursListeScreen> {
  final _rechercheController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(utilisateursListeProvider.notifier).chargerPageSuivante();
    }
  }

  void _appliquerRecherche(String valeur) {
    final filtres = ref.read(utilisateursListeProvider).filtres;
    ref.read(utilisateursListeProvider.notifier).appliquerFiltres(
          FiltresUtilisateursAdmin(
            recherche: valeur.trim().isEmpty ? null : valeur.trim(),
            role: filtres.role,
            actif: filtres.actif,
            verrouille: filtres.verrouille,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(utilisateursListeProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.navUtilisateurs, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.vertOlive,
        onPressed: () => afficherFeuilleCreerUtilisateur(
          context,
          onCree: () => ref.read(utilisateursListeProvider.notifier).charger(),
        ),
        icon: const Icon(Icons.person_add_alt, color: AppColors.blanc),
        label: Text(l10n.creerCompteBouton, style: AppTextStyles.boutonPrincipal),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _rechercheController,
              onSubmitted: _appliquerRecherche,
              decoration: InputDecoration(
                hintText: l10n.rechercherUtilisateurPlaceholder,
                prefixIcon: const Icon(Icons.search, color: AppColors.grisMoyen),
                filled: true,
                fillColor: AppColors.blanc,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grisLigne),
                ),
              ),
            ),
          ),
          _BarreFiltres(filtres: state.filtres),
          Expanded(child: _corps(context, state)),
        ],
      ),
    );
  }

  Widget _corps(BuildContext context, UtilisateursListeState state) {
    final l10n = context.l10n;

    if (state.utilisateurs == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.utilisateurs == null && state.echec != null) {
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
                onPressed: () => ref.read(utilisateursListeProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final utilisateurs = state.utilisateurs ?? const [];
    if (utilisateurs.isEmpty) {
      return Center(child: Text(l10n.aucunUtilisateurTexte, style: AppTextStyles.sousTexteBienvenue));
    }

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(utilisateursListeProvider.notifier).charger(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: utilisateurs.length + (state.chargementPageSuivante ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= utilisateurs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppColors.vertOlive)),
            );
          }
          return _CarteUtilisateur(utilisateur: utilisateurs[index]);
        },
      ),
    );
  }
}

class _BarreFiltres extends ConsumerWidget {
  final FiltresUtilisateursAdmin filtres;

  const _BarreFiltres({required this.filtres});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _PucheFiltre(
              libelle: l10n.roleAdministrateurLabel,
              selectionne: filtres.role == 'administrateur',
              onTap: () => ref.read(utilisateursListeProvider.notifier).appliquerFiltres(
                    FiltresUtilisateursAdmin(
                      recherche: filtres.recherche,
                      role: filtres.role == 'administrateur' ? null : 'administrateur',
                      actif: filtres.actif,
                      verrouille: filtres.verrouille,
                    ),
                  ),
            ),
            const SizedBox(width: 8),
            _PucheFiltre(
              libelle: l10n.statutActifLabel,
              selectionne: filtres.actif == true,
              onTap: () => ref.read(utilisateursListeProvider.notifier).appliquerFiltres(
                    FiltresUtilisateursAdmin(
                      recherche: filtres.recherche,
                      role: filtres.role,
                      actif: filtres.actif == true ? null : true,
                      verrouille: filtres.verrouille,
                    ),
                  ),
            ),
            const SizedBox(width: 8),
            _PucheFiltre(
              libelle: l10n.filtreVerrouilleLabel,
              selectionne: filtres.verrouille == true,
              onTap: () => ref.read(utilisateursListeProvider.notifier).appliquerFiltres(
                    FiltresUtilisateursAdmin(
                      recherche: filtres.recherche,
                      role: filtres.role,
                      actif: filtres.actif,
                      verrouille: filtres.verrouille == true ? null : true,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PucheFiltre extends StatelessWidget {
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  const _PucheFiltre({required this.libelle, required this.selectionne, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selectionne ? AppColors.vertOlive : AppColors.blanc,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selectionne ? AppColors.vertOlive : AppColors.grisLigne),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selectionne ? AppColors.blanc : AppColors.grisMoyen,
          ),
        ),
      ),
    );
  }
}

class _CarteUtilisateur extends StatelessWidget {
  final UtilisateurAdminEntity utilisateur;

  const _CarteUtilisateur({required this.utilisateur});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName);
    final couleurStatut = !utilisateur.estActif
        ? AppColors.grisMoyen
        : (utilisateur.estVerrouille ? AppColors.erreur : AppColors.succes);
    final libelleStatut = !utilisateur.estActif
        ? l10n.statutInactifLabel
        : (utilisateur.estVerrouille ? l10n.filtreVerrouilleLabel : l10n.statutActifLabel);

    return InkWell(
      onTap: () => context.push('/admin/utilisateurs/${utilisateur.id}'),
      borderRadius: BorderRadius.circular(16),
      child: CarteStylisee(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    utilisateur.nom,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    utilisateur.email,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    utilisateur.dateDerniereConnexion == null
                        ? l10n.jamaisConnecteLabel
                        : formatDate.format(utilisateur.dateDerniereConnexion!),
                    style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: couleurStatut.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    libelleStatut,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleurStatut),
                  ),
                ),
                const SizedBox(height: 4),
                if (utilisateur.estAdministrateur)
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.vertOliveFonce),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
