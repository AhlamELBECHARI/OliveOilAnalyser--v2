import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../analyseur/domain/entities/etat_connexion_analyseur_entity.dart';
import '../../../analyseur/domain/entities/info_appareil_analyseur_entity.dart';

/// Carte "Connexion & Instrument" — la plus importante du cahier des
/// charges : reflète l'état RÉEL de l'analyseur (voir AnalyseurRepository),
/// jamais une donnée fictive. Identique que l'implémentation active soit le
/// simulateur ou le vrai Bluetooth (voir core/di/injection_container.dart).
class CarteConnexionInstrument extends StatelessWidget {
  final EtatConnexionAnalyseurEntity etatConnexion;
  final InfoAppareilAnalyseurEntity? infoAppareil;
  final VoidCallback onReessayer;

  const CarteConnexionInstrument({
    super.key,
    required this.etatConnexion,
    required this.infoAppareil,
    required this.onReessayer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connecte = etatConnexion.estConnecte;
    final couleurBadge = connecte
        ? AppColors.succes
        : (etatConnexion.etat == EtatConnexion.erreur ? AppColors.erreur : AppColors.grisMoyen);
    final libelleBadge = connecte
        ? l10n.connecte
        : (etatConnexion.etat == EtatConnexion.recherche ? l10n.etatRecherche : l10n.deconnecte);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_antenna, size: 20, color: AppColors.vertOliveFonce),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.carteConnexionInstrumentTitre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleurBadge.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: couleurBadge, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      libelleBadge,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleurBadge),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (infoAppareil != null)
            _InfoAppareil(info: infoAppareil!)
          else
            _AucunAppareil(etatConnexion: etatConnexion, onReessayer: onReessayer),
        ],
      ),
    );
  }
}

class _InfoAppareil extends StatelessWidget {
  final InfoAppareilAnalyseurEntity info;

  const _InfoAppareil({required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
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
              const SizedBox(height: 2),
              Text(
                '${l10n.numeroSerieLabel}: ${info.numeroSerie} • ${l10n.firmwareLabel} ${info.firmware}',
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    );
  }
}

class _AucunAppareil extends StatelessWidget {
  final EtatConnexionAnalyseurEntity etatConnexion;
  final VoidCallback onReessayer;

  const _AucunAppareil({required this.etatConnexion, required this.onReessayer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enRecherche = etatConnexion.etat == EtatConnexion.recherche;

    return Row(
      children: [
        if (enRecherche)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertOlive),
          )
        else
          const Icon(Icons.bluetooth_disabled, size: 20, color: AppColors.grisMoyen),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            enRecherche
                ? l10n.rechercheInstrumentTexte
                : (etatConnexion.messageErreur ?? l10n.aucunInstrumentConnecte),
            style: AppTextStyles.sousTexteBienvenue,
          ),
        ),
        if (!enRecherche)
          TextButton(
            onPressed: onReessayer,
            child: Text(l10n.reessayerConnexionBouton, style: AppTextStyles.lienAction),
          ),
      ],
    );
  }
}
