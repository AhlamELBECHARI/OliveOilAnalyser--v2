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

/// Écran d'accueil admin (design cahier des charges espace admin) — une
/// seule requête (GET /api/admin/supervision/) alimente tout l'écran,
/// aucun parcours d'analyse ici.
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
        title: Text(l10n.supervisionTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
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

class _LigneChamp extends StatelessWidget {
  final String libelle;
  final String valeur;
  final Color? couleurValeur;

  const _LigneChamp({required this.libelle, required this.valeur, this.couleurValeur});

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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: couleurValeur ?? AppColors.grisFonce,
            ),
          ),
        ],
      ),
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

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitreCarte(l10n.etatSystemeTitre),
          const SizedBox(height: 8),
          _LigneChamp(
            libelle: l10n.apiLabel,
            valeur: etat.apiDisponible ? l10n.disponibleLabel : l10n.indisponibleLabel,
            couleurValeur: etat.apiDisponible ? AppColors.succes : AppColors.erreur,
          ),
          _LigneChamp(
            libelle: l10n.baseDeDonneesLabel,
            valeur:
                etat.baseDeDonneesDisponible ? l10n.disponibleLabel : l10n.indisponibleLabel,
            couleurValeur: etat.baseDeDonneesDisponible ? AppColors.succes : AppColors.erreur,
          ),
          _LigneChamp(libelle: l10n.tailleBaseLabel, valeur: _formaterOctets(etat.tailleBaseOctets)),
          _LigneChamp(
            libelle: l10n.derniereSauvegardeLabel,
            valeur: etat.dateDerniereSauvegarde == null
                ? l10n.nonDisponibleLabel
                : formatDate.format(etat.dateDerniereSauvegarde!),
          ),
          _LigneChamp(
            libelle: l10n.analyseursRecentsLabel,
            valeur: etat.nombreAnalyseursRecents?.toString() ?? l10n.nonDisponibleLabel,
          ),
        ],
      ),
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
          const SizedBox(height: 8),
          _LigneChamp(
            libelle: l10n.utilisateursConnectesLabel,
            valeur: '${activite.utilisateursConnectes}',
          ),
          _LigneChamp(libelle: l10n.sessionsActivesLabel, valeur: '${activite.sessionsActives}'),
          _LigneChamp(
            libelle: l10n.analysesAujourdHuiLabel,
            valeur: '${activite.analysesAujourdHui}',
          ),
          _LigneChamp(
            libelle: l10n.analysesSemaineLabel,
            valeur: '${activite.analysesCetteSemaine}',
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
          _TitreCarte(l10n.alertesNonResoluesTitre),
          const SizedBox(height: 8),
          if (alertes.isEmpty)
            Text(l10n.aucuneAlerteNonResolueTexte, style: AppTextStyles.sousTexteBienvenue)
          else
            for (var i = 0; i < alertes.length; i++) ...[
              if (i > 0) const Divider(height: 16, color: AppColors.grisLigne),
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
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
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
          const SizedBox(height: 8),
          if (operateurs.isEmpty)
            Text(l10n.aucuneActiviteOperateurTexte, style: AppTextStyles.sousTexteBienvenue)
          else
            for (var i = 0; i < operateurs.length; i++) ...[
              if (i > 0) const Divider(height: 16, color: AppColors.grisLigne),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      operateurs[i].nom,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grisFonce),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${operateurs[i].nombreAnalyses}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce),
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
    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitreCarte(l10n.anomaliesTitre),
          const SizedBox(height: 8),
          _LigneChamp(
            libelle: l10n.comptesVerrouillesLabel,
            valeur: '${anomalies.comptesVerrouilles}',
            couleurValeur: anomalies.comptesVerrouilles > 0 ? AppColors.orangeIcone : null,
          ),
          _LigneChamp(
            libelle: l10n.modelesDepreciesUtilisesLabel,
            valeur: '${anomalies.modelesDepreciesReferences}',
            couleurValeur: anomalies.modelesDepreciesReferences > 0 ? AppColors.orangeIcone : null,
          ),
        ],
      ),
    );
  }
}
