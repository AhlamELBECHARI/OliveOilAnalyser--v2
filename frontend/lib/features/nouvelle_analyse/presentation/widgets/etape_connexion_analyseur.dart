import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../analyseur/domain/entities/etat_connexion_analyseur_entity.dart';
import '../../../analyseur/domain/entities/info_appareil_analyseur_entity.dart';
import '../../../analyseur/presentation/screens/configuration_appareil_screen.dart';

/// Étape 1/4 du parcours Analyse : écran d'entrée qui gère la liaison avec
/// l'analyseur NIR. Rend visible la connexion automatique existante (voir
/// AnalyseurRepository.connecterAutomatiquement, toujours le comportement
/// par défaut au chargement de l'écran) et donne un recours en cas
/// d'échec — elle ne la remplace jamais.
///
/// Ne montre pas de "qualité du signal" séparée du niveau de batterie : le
/// protocole Bluetooth Classic (SPP) utilisé n'expose pas de RSSI exploitable
/// (voir data/protocole/protocole_spectrometre.dart) et ce projet ne fabrique
/// jamais de métrique fictive pour combler l'UI.
class EtapeConnexionAnalyseur extends StatelessWidget {
  final EtatConnexionAnalyseurEntity etatConnexion;
  final InfoAppareilAnalyseurEntity? infoAppareil;
  final VoidCallback onReessayer;
  final VoidCallback onContinuer;
  final VoidCallback onContinuerSansAppareil;

  const EtapeConnexionAnalyseur({
    super.key,
    required this.etatConnexion,
    required this.infoAppareil,
    required this.onReessayer,
    required this.onContinuer,
    required this.onContinuerSansAppareil,
  });

  String _titre(AppLocalizations l10n) {
    if (etatConnexion.estConnecte) return l10n.connecte;
    if (etatConnexion.etat == EtatConnexion.recherche) return l10n.etapeConnexionRechercheTitre;
    return l10n.etapeConnexionEchecTitre;
  }

  String _sousTitre(AppLocalizations l10n) {
    if (etatConnexion.etat == EtatConnexion.recherche) return l10n.etapeConnexionRechercheTexte;
    return etatConnexion.messageErreur ?? l10n.etapeConnexionEchecTexteGenerique;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enRecherche = etatConnexion.etat == EtatConnexion.recherche;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              _Icone(etat: etatConnexion.etat),
              const SizedBox(height: 20),
              Text(
                _titre(l10n),
                textAlign: TextAlign.center,
                style: AppTextStyles.bienvenue.copyWith(fontSize: 18),
              ),
              if (!etatConnexion.estConnecte) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _sousTitre(l10n),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sousTexteBienvenue,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (etatConnexion.estConnecte && infoAppareil != null) ...[
          _CarteAppareilConnecte(info: infoAppareil!),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertOlive,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onContinuer,
              child: Text(l10n.continuerBouton, style: AppTextStyles.boutonPrincipal),
            ),
          ),
        ] else if (!enRecherche) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertOlive,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onReessayer,
              child: Text(l10n.reessayerConnexionBouton, style: AppTextStyles.boutonPrincipal),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConfigurationAppareilScreen()),
              ),
              icon: const Icon(Icons.settings_bluetooth_outlined, size: 18),
              label: Text(l10n.configurerAppareilLien),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: onContinuerSansAppareil,
            child: Text(
              l10n.continuerSansAppareilLien,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grisMoyen,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Icone extends StatelessWidget {
  final EtatConnexion etat;

  const _Icone({required this.etat});

  @override
  Widget build(BuildContext context) {
    final (couleur, icone) = switch (etat) {
      EtatConnexion.connecte => (AppColors.succes, Icons.bluetooth_connected),
      EtatConnexion.recherche => (AppColors.vertOlive, null),
      EtatConnexion.erreur => (AppColors.erreur, Icons.bluetooth_disabled),
      EtatConnexion.deconnecte => (AppColors.grisMoyen, Icons.bluetooth_disabled),
    };

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(color: couleur.withValues(alpha: 0.12), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: icone == null
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.vertOlive),
            )
          : Icon(icone, size: 40, color: couleur),
    );
  }
}

class _CarteAppareilConnecte extends StatelessWidget {
  final InfoAppareilAnalyseurEntity info;

  const _CarteAppareilConnecte({required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grisLigne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.fond,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grisLigne),
                ),
                child: const Icon(Icons.sensors, color: AppColors.vertOliveFonce),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.nom,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                    ),
                    Text(info.type, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              if (info.niveauBatteriePourcentage != null)
                Column(
                  children: [
                    const Icon(Icons.battery_std, size: 18, color: AppColors.grisMoyen),
                    Text(
                      '${info.niveauBatteriePourcentage}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(height: 24, color: AppColors.grisLigne),
          Row(
            children: [
              Expanded(
                child: _ChampInfo(libelle: l10n.numeroSerieLabel, valeur: info.numeroSerie),
              ),
              Expanded(
                child: _ChampInfo(libelle: l10n.firmwareLabel, valeur: info.firmware),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChampInfo extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _ChampInfo({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen)),
        const SizedBox(height: 2),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
        ),
      ],
    );
  }
}
