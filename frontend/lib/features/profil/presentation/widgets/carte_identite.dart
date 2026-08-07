import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/profil_entity.dart';

/// Carte identité de l'écran Profil (design/6-profil.png) : avatar (photo
/// réelle si renseignée, sinon initiales calculées depuis le nom), bouton
/// appareil photo, badge de rôle, fonction/laboratoire/institution, puis
/// Email / Téléphone / Membre depuis.
class CarteIdentite extends StatelessWidget {
  final ProfilEntity profil;
  final VoidCallback onChangerPhoto;
  final bool televersementEnCours;

  const CarteIdentite({
    super.key,
    required this.profil,
    required this.onChangerPhoto,
    required this.televersementEnCours,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final couleurBadge = profil.estAdministrateur ? AppColors.vertOlive : AppColors.bleuIcone;
    final fondBadge = profil.estAdministrateur ? AppColors.evooFond : AppColors.bleuFond;
    final libelleRole = profil.estAdministrateur ? l10n.roleAdministrateurLabel : l10n.roleUtilisateurLabel;
    final membreDepuis = DateFormat.yMMMM(l10n.localeName).format(profil.dateCreation);

    return CarteStylisee(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.vertOlive,
                    backgroundImage:
                        profil.photoProfilUrl != null ? NetworkImage(profil.photoProfilUrl!) : null,
                    child: profil.photoProfilUrl == null
                        ? Text(
                            profil.initiales,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.blanc,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: televersementEnCours ? null : onChangerPhoto,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.vertOliveFonce,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blanc, width: 2),
                        ),
                        child: televersementEnCours
                            ? const Padding(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                              )
                            : const Icon(Icons.photo_camera, size: 13, color: AppColors.blanc),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          profil.nom,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.grisFonce),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: fondBadge, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            libelleRole,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleurBadge),
                          ),
                        ),
                      ],
                    ),
                    if (profil.fonction.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(profil.fonction, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 13)),
                    ],
                    if (profil.laboratoire.isNotEmpty)
                      Text(profil.laboratoire, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 13)),
                    if (profil.institution.isNotEmpty)
                      Text(profil.institution, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.grisLigne, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ChampIdentite(
                  libelle: l10n.champEmail,
                  valeur: profil.email,
                ),
              ),
              Expanded(
                child: _ChampIdentite(
                  libelle: l10n.champTelephone,
                  valeur: profil.telephone.isEmpty ? '—' : profil.telephone,
                ),
              ),
              Expanded(
                child: _ChampIdentite(
                  libelle: l10n.membreDepuisLabel,
                  valeur: membreDepuis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChampIdentite extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _ChampIdentite({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
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
