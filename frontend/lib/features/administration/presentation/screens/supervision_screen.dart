import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/supervision_entity.dart';
import '../providers/supervision_provider.dart';
import '../widgets/entete_ecran_admin.dart';

/// Écran d'accueil admin (design cahier des charges espace admin) — une
/// seule requête (GET /api/admin/supervision/) alimente tout l'écran,
/// aucun parcours d'analyse ici. Vocabulaire visuel repris du Dashboard
/// utilisateur (badges d'icônes colorés, chiffres en gras, point de statut)
/// sans en copier la mise en page — le contenu (état système, alertes,
/// opérateurs) n'a pas la même forme que les cartes du Dashboard.
class SupervisionScreen extends ConsumerWidget {
  const SupervisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(supervisionProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: EnTeteEcranAdmin(
          icone: Icons.dashboard_outlined,
          couleur: AppColors.vertOliveFonce,
          fond: AppColors.evooFond,
          titre: l10n.supervisionTitre,
          sousTitre: l10n.supervisionSousTitre,
        ),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, SupervisionState state) {
    final l10n = context.l10n;

    if (state.supervision == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.supervision == null && state.echec != null) {
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
                onPressed: () => ref.read(supervisionProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final supervision = state.supervision;
    if (supervision == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(supervisionProvider.notifier).charger(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _CarteEtatSysteme(etat: supervision.etatSysteme),
          const SizedBox(height: 16),
          _CarteActiviteJour(activite: supervision.activiteJour),
          const SizedBox(height: 16),
          _CarteAlertes(alertes: supervision.alertesNonResolues),
          const SizedBox(height: 16),
          _CarteActiviteOperateur(operateurs: supervision.activiteParOperateur),
          const SizedBox(height: 16),
          _CarteAnomalies(anomalies: supervision.anomalies),
        ],
      ),
    );
  }
}

class _TitreCarte extends StatelessWidget {
  final String texte;

  const _TitreCarte(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
    );
  }
}

/// Badge d'icône colorée + chiffre en gras + libellé — le vocabulaire
/// visuel repris du Dashboard (CarteStatistique), décliné en mini-format
/// pour tenir plusieurs métriques dans une seule carte.
class _StatBadge extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String valeur;
  final String libelle;

  const _StatBadge({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.valeur,
    required this.libelle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icon(icone, color: couleur, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valeur,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
              ),
              Text(
                libelle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11, height: 1.15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formaterOctets(int octets) {
  const unites = ['o', 'Ko', 'Mo', 'Go', 'To'];
  var valeur = octets.toDouble();
  var indice = 0;
  while (valeur >= 1024 && indice < unites.length - 1) {
    valeur /= 1024;
    indice++;
  }
  return '${valeur.toStringAsFixed(valeur < 10 && indice > 0 ? 1 : 0)} ${unites[indice]}';
}

class _CarteEtatSysteme extends StatelessWidget {
  final EtatSystemeEntity etat;

  const _CarteEtatSysteme({required this.etat});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMMMd(l10n.localeName).add_Hm();
    final toutDisponible = etat.apiDisponible && etat.baseDeDonneesDisponible;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: toutDisponible ? AppColors.succes : AppColors.erreur,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              _TitreCarte(l10n.etatSystemeTitre),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  icone: Icons.cloud_outlined,
                  couleur: etat.apiDisponible ? AppColors.succes : AppColors.erreur,
                  fond: etat.apiDisponible
                      ? AppColors.evooFond
                      : AppColors.erreur.withValues(alpha: 0.12),
                  valeur: etat.apiDisponible ? l10n.disponibleLabel : l10n.indisponibleLabel,
                  libelle: l10n.apiLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBadge(
                  icone: Icons.storage_outlined,
                  couleur: etat.baseDeDonneesDisponible ? AppColors.succes : AppColors.erreur,
                  fond: etat.baseDeDonneesDisponible
                      ? AppColors.evooFond
                      : AppColors.erreur.withValues(alpha: 0.12),
                  valeur: etat.baseDeDonneesDisponible ? l10n.disponibleLabel : l10n.indisponibleLabel,
                  libelle: l10n.baseDeDonneesLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.grisLigne),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  libelle: l10n.tailleBaseLabel,
                  valeur: _formaterOctets(etat.tailleBaseOctets),
                ),
              ),
              Expanded(
                child: _MiniInfo(
                  libelle: l10n.derniereSauvegardeLabel,
                  valeur: etat.dateDerniereSauvegarde == null
                      ? l10n.nonDisponibleLabel
                      : formatDate.format(etat.dateDerniereSauvegarde!),
                ),
              ),
              Expanded(
                child: _MiniInfo(
                  libelle: l10n.analyseursRecentsLabel,
                  valeur: etat.nombreAnalyseursRecents?.toString() ?? l10n.nonDisponibleLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _MiniInfo({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
        ),
      ],
    );
  }
}

class _CarteActiviteJour extends StatelessWidget {
  final ActiviteJourEntity activite;

  const _CarteActiviteJour({required this.activite});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitreCarte(l10n.activiteJourTitre),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  icone: Icons.people_outline,
                  couleur: AppColors.bleuIcone,
                  fond: AppColors.bleuFond,
                  valeur: '${activite.utilisateursConnectes}',
                  libelle: l10n.utilisateursConnectesLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBadge(
                  icone: Icons.vpn_key_outlined,
                  couleur: AppColors.orangeIcone,
                  fond: AppColors.orangeFond,
                  valeur: '${activite.sessionsActives}',
                  libelle: l10n.sessionsActivesLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  icone: Icons.science_outlined,
                  couleur: AppColors.vertOliveFonce,
                  fond: AppColors.evooFond,
                  valeur: '${activite.analysesAujourdHui}',
                  libelle: l10n.analysesAujourdHuiLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBadge(
                  icone: Icons.calendar_month_outlined,
                  couleur: AppColors.vertOlive,
                  fond: AppColors.evooFond,
                  valeur: '${activite.analysesCetteSemaine}',
                  libelle: l10n.analysesSemaineLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarteAlertes extends ConsumerWidget {
  final List<AlerteSupervisionEntity> alertes;

  const _CarteAlertes({required this.alertes});

  Color _couleurGravite(String niveau) {
    return switch (niveau) {
      'critique' => AppColors.erreur,
      'avertissement' => AppColors.orangeIcone,
      _ => AppColors.grisMoyen,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _TitreCarte(l10n.alertesNonResoluesTitre)),
              if (alertes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.erreur.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${alertes.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.erreur),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (alertes.isEmpty)
            Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: AppColors.succes),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.aucuneAlerteNonResolueTexte, style: AppTextStyles.sousTexteBienvenue),
                ),
              ],
            )
          else
            for (var i = 0; i < alertes.length; i++) ...[
              if (i > 0) const Divider(height: 20, color: AppColors.grisLigne),
              _LigneAlerte(
                alerte: alertes[i],
                couleur: _couleurGravite(alertes[i].niveauGravite),
                onResoudre: () =>
                    ref.read(supervisionProvider.notifier).resoudreAlerte(alertes[i].id),
              ),
            ],
        ],
      ),
    );
  }
}

class _LigneAlerte extends StatelessWidget {
  final AlerteSupervisionEntity alerte;
  final Color couleur;
  final VoidCallback onResoudre;

  const _LigneAlerte({required this.alerte, required this.couleur, required this.onResoudre});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: couleur.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(Icons.warning_amber_rounded, size: 15, color: couleur),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerte.message,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grisFonce),
                ),
                if (alerte.numeroEchantillon != null)
                  Text(
                    alerte.numeroEchantillon!,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
        TextButton(onPressed: onResoudre, child: Text(l10n.resoudreBouton)),
      ],
    );
  }
}

class _CarteActiviteOperateur extends StatelessWidget {
  final List<ActiviteOperateurEntity> operateurs;

  const _CarteActiviteOperateur({required this.operateurs});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitreCarte(l10n.activiteOperateurTitre),
          const SizedBox(height: 12),
          if (operateurs.isEmpty)
            Text(l10n.aucuneActiviteOperateurTexte, style: AppTextStyles.sousTexteBienvenue)
          else
            for (var i = 0; i < operateurs.length; i++) ...[
              if (i > 0) const Divider(height: 18, color: AppColors.grisLigne),
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(color: AppColors.evooFond, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        operateurs[i].nom.isEmpty ? '?' : operateurs[i].nom[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.vertOliveFonce,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      operateurs[i].nom,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grisFonce),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${operateurs[i].nombreAnalyses}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.vertOliveFonce),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

class _CarteAnomalies extends StatelessWidget {
  final AnomaliesEntity anomalies;

  const _CarteAnomalies({required this.anomalies});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final aDesComptesVerrouilles = anomalies.comptesVerrouilles > 0;
    final aDesModelesDeprecies = anomalies.modelesDepreciesReferences > 0;

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitreCarte(l10n.anomaliesTitre),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  icone: Icons.lock_outline,
                  couleur: aDesComptesVerrouilles ? AppColors.orangeIcone : AppColors.succes,
                  fond: aDesComptesVerrouilles ? AppColors.orangeFond : AppColors.evooFond,
                  valeur: '${anomalies.comptesVerrouilles}',
                  libelle: l10n.comptesVerrouillesLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBadge(
                  icone: Icons.warning_amber_outlined,
                  couleur: aDesModelesDeprecies ? AppColors.orangeIcone : AppColors.succes,
                  fond: aDesModelesDeprecies ? AppColors.orangeFond : AppColors.evooFond,
                  valeur: '${anomalies.modelesDepreciesReferences}',
                  libelle: l10n.modelesDepreciesUtilisesLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
