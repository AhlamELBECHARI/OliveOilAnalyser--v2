import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../profil/domain/entities/session_entity.dart';
import '../../domain/entities/utilisateur_admin_entity.dart';
import '../providers/utilisateur_detail_provider.dart';

/// Fiche détaillée d'un utilisateur, avec les actions de gestion admin —
/// voir comptes.services côté backend pour les garde-fous (auto-modification,
/// dernier administrateur) appliqués à chaque action.
class UtilisateurDetailScreen extends ConsumerWidget {
  final int utilisateurId;

  const UtilisateurDetailScreen({super.key, required this.utilisateurId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(utilisateurDetailProvider(utilisateurId));

    ref.listen(utilisateurDetailProvider(utilisateurId), (previous, next) {
      if (next.echecAction != null && next.echecAction != previous?.echecAction) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.echecAction!.messageLocalise(context))));
      }
      if (next.resetDeclenche && previous?.resetDeclenche != true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.resetDeclencheMessage)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(
          state.utilisateur?.nom ?? l10n.navUtilisateurs,
          style: AppTextStyles.bienvenue.copyWith(fontSize: 18),
        ),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, UtilisateurDetailState state) {
    final l10n = context.l10n;

    if (state.utilisateur == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.utilisateur == null && state.echec != null) {
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
                onPressed: () => ref.read(utilisateurDetailProvider(utilisateurId).notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final utilisateur = state.utilisateur;
    if (utilisateur == null) return const SizedBox.shrink();

    final formatDate = DateFormat.yMMMd(l10n.localeName).add_Hm();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CarteStylisee(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                utilisateur.email,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
              ),
              const SizedBox(height: 8),
              _LigneChamp(
                libelle: l10n.filtreRoleLabel,
                valeur: utilisateur.estAdministrateur
                    ? l10n.roleAdministrateurLabel
                    : l10n.roleUtilisateurLabel,
              ),
              _LigneChamp(
                libelle: l10n.filtreStatutLabel,
                valeur: utilisateur.estActif ? l10n.statutActifLabel : l10n.statutInactifLabel,
                couleur: utilisateur.estActif ? AppColors.succes : AppColors.erreur,
              ),
              if (utilisateur.estVerrouille)
                _LigneChamp(
                  libelle: l10n.filtreVerrouilleLabel,
                  valeur: formatDate.format(utilisateur.verrouilleJusquA!),
                  couleur: AppColors.erreur,
                ),
              _LigneChamp(
                libelle: l10n.dateDerniereConnexionLabel,
                valeur: utilisateur.dateDerniereConnexion == null
                    ? l10n.jamaisConnecteLabel
                    : formatDate.format(utilisateur.dateDerniereConnexion!),
              ),
              _LigneChamp(
                libelle: l10n.dateInscriptionLabel,
                valeur: formatDate.format(utilisateur.dateCreation),
              ),
              _LigneChamp(
                libelle: l10n.nombreAnalysesLabel,
                valeur: '${utilisateur.nombreAnalyses}',
              ),
              if (utilisateur.tentativesEchouees > 0)
                _LigneChamp(
                  libelle: l10n.tentativesEchoueesLabel,
                  valeur: '${utilisateur.tentativesEchouees}',
                  couleur: AppColors.orangeIcone,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CarteActions(utilisateur: utilisateur, enCours: state.actionEnCours),
        const SizedBox(height: 16),
        _CarteSessions(
          utilisateurId: utilisateurId,
          sessions: state.sessions,
          enCoursDeRevocation: state.sessionsEnCoursDeRevocation,
        ),
      ],
    );
  }
}

class _LigneChamp extends StatelessWidget {
  final String libelle;
  final String valeur;
  final Color? couleur;

  const _LigneChamp({required this.libelle, required this.valeur, this.couleur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: const TextStyle(fontSize: 13, color: AppColors.grisMoyen)),
          Text(
            valeur,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: couleur ?? AppColors.grisFonce),
          ),
        ],
      ),
    );
  }
}

class _CarteActions extends ConsumerWidget {
  final UtilisateurAdminEntity utilisateur;
  final bool enCours;

  const _CarteActions({required this.utilisateur, required this.enCours});

  Future<void> _confirmer(BuildContext context, {required String texte, required VoidCallback onConfirmer}) async {
    final l10n = context.l10n;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(texte),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.annulerBouton)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.confirmerBouton)),
        ],
      ),
    );
    if (confirme == true) onConfirmer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(utilisateurDetailProvider(utilisateur.id).notifier);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.modifierRoleAction,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 12),
          _BoutonAction(
            icone: Icons.shield_outlined,
            libelle: utilisateur.estAdministrateur ? l10n.roleUtilisateurLabel : l10n.roleAdministrateurLabel,
            enCours: enCours,
            onPressed: () => _confirmer(
              context,
              texte: utilisateur.estAdministrateur
                  ? l10n.confirmerRetrograderTexte
                  : l10n.confirmerChangerRoleAdminTexte,
              onConfirmer: () => notifier.changerRole(
                utilisateur.estAdministrateur ? 'utilisateur' : 'administrateur',
              ),
            ),
          ),
          _BoutonAction(
            icone: utilisateur.estActif ? Icons.block_outlined : Icons.check_circle_outline,
            libelle: utilisateur.estActif ? l10n.desactiverCompteAction : l10n.activerCompteAction,
            couleur: utilisateur.estActif ? AppColors.erreur : AppColors.succes,
            enCours: enCours,
            onPressed: () => utilisateur.estActif
                ? _confirmer(
                    context,
                    texte: l10n.confirmerDesactivationTexte,
                    onConfirmer: () => notifier.definirActivation(false),
                  )
                : notifier.definirActivation(true),
          ),
          if (utilisateur.estVerrouille)
            _BoutonAction(
              icone: Icons.lock_open_outlined,
              libelle: l10n.deverrouillerCompteAction,
              enCours: enCours,
              onPressed: notifier.deverrouiller,
            ),
          _BoutonAction(
            icone: Icons.mail_outline,
            libelle: l10n.declencherResetAction,
            enCours: enCours,
            onPressed: notifier.declencherResetMotDePasse,
          ),
          _BoutonAction(
            icone: Icons.article_outlined,
            libelle: l10n.voirAnalysesUtilisateurAction,
            enCours: enCours,
            onPressed: () => context.go(
              '/admin/analyses',
              extra: {'operateurId': utilisateur.id, 'operateurNom': utilisateur.nom},
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonAction extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final Color? couleur;
  final bool enCours;
  final VoidCallback onPressed;

  const _BoutonAction({
    required this.icone,
    required this.libelle,
    this.couleur,
    required this.enCours,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final couleurEffective = couleur ?? AppColors.grisFonce;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: couleurEffective),
      title: Text(libelle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: couleurEffective)),
      trailing: enCours ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      onTap: enCours ? null : onPressed,
    );
  }
}

class _CarteSessions extends ConsumerWidget {
  final int utilisateurId;
  final List<SessionEntity>? sessions;
  final Set<int> enCoursDeRevocation;

  const _CarteSessions({
    required this.utilisateurId,
    required this.sessions,
    required this.enCoursDeRevocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName).add_Hm();

    if (sessions == null) {
      return const CarteStylisee(
        child: Center(child: CircularProgressIndicator(color: AppColors.vertOlive)),
      );
    }

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sessionsActivesTitre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
          ),
          const SizedBox(height: 8),
          if (sessions!.isEmpty)
            Text(l10n.aucuneSessionMessage, style: AppTextStyles.sousTexteBienvenue)
          else
            for (final session in sessions!) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.sessionCreeeLabel(formatDate.format(session.dateCreation)),
                      style: const TextStyle(fontSize: 12, color: AppColors.grisFonce),
                    ),
                  ),
                  if (enCoursDeRevocation.contains(session.id))
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.erreur),
                    )
                  else
                    TextButton(
                      onPressed: () => ref
                          .read(utilisateurDetailProvider(utilisateurId).notifier)
                          .revoquerSession(session.id),
                      child: Text(
                        l10n.revoquerSessionBouton,
                        style: const TextStyle(color: AppColors.erreur, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const Divider(height: 16, color: AppColors.grisLigne),
            ],
        ],
      ),
    );
  }
}
