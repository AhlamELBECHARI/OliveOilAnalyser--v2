import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../profil/presentation/providers/profil_provider.dart';
import '../../domain/entities/configuration_entity.dart';
import '../providers/configuration_provider.dart';

/// Sous-écran "Préférences d'analyse" — seuils de conformité/qualité
/// (comptes.models.Configuration côté backend). Lecture seule pour un
/// utilisateur standard, modifiable par un administrateur uniquement (même
/// permission que l'endpoint /api/configuration/ existant) — le rôle vient
/// de profilProvider, déjà chargé par l'écran Profil parent.
class PreferencesAnalyseScreen extends ConsumerStatefulWidget {
  const PreferencesAnalyseScreen({super.key});

  @override
  ConsumerState<PreferencesAnalyseScreen> createState() => _PreferencesAnalyseScreenState();
}

class _PreferencesAnalyseScreenState extends ConsumerState<PreferencesAnalyseScreen> {
  final Map<String, TextEditingController> _controleurs = {};
  bool _initialise = false;

  void _initialiser(ConfigurationEntity configuration) {
    if (_initialise) return;
    _initialise = true;
    _controleurs['acidite'] = TextEditingController(text: configuration.seuilConformiteAcidite.toString());
    _controleurs['peroxyde'] = TextEditingController(text: configuration.seuilConformitePeroxyde.toString());
    _controleurs['evoo'] = TextEditingController(text: configuration.seuilAciditeEvoo.toString());
    _controleurs['voo'] = TextEditingController(text: configuration.seuilAciditeVoo.toString());
  }

  @override
  void dispose() {
    for (final controleur in _controleurs.values) {
      controleur.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer(ConfigurationEntity actuelle) async {
    final l10n = context.l10n;
    final nouvelle = ConfigurationEntity(
      notificationsActives: actuelle.notificationsActives,
      seuilConformiteAcidite: double.tryParse(_controleurs['acidite']!.text) ?? actuelle.seuilConformiteAcidite,
      seuilConformitePeroxyde: double.tryParse(_controleurs['peroxyde']!.text) ?? actuelle.seuilConformitePeroxyde,
      seuilAciditeEvoo: double.tryParse(_controleurs['evoo']!.text) ?? actuelle.seuilAciditeEvoo,
      seuilAciditeVoo: double.tryParse(_controleurs['voo']!.text) ?? actuelle.seuilAciditeVoo,
    );
    final succes = await ref.read(configurationProvider.notifier).modifier(nouvelle);
    if (!mounted) return;
    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.seuilsMisAJourMessage)));
    } else {
      final echec = ref.read(configurationProvider).echec;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(echec?.messageLocalise(context) ?? l10n.erreurServeur)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(configurationProvider);
    final estAdmin = ref.watch(profilProvider).profil?.estAdministrateur ?? false;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.preferencesAnalyseTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: state.configuration == null
          ? (state.enChargement
              ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
              : Center(
                  child: Text(
                    state.echec?.messageLocalise(context) ?? l10n.erreurServeur,
                    style: AppTextStyles.sousTexteBienvenue,
                  ),
                ))
          : Builder(builder: (context) {
              _initialiser(state.configuration!);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!estAdmin)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bleuFond,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.bleuIcone, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.lectureSeuleAdministrateurMessage,
                              style: const TextStyle(fontSize: 12, color: AppColors.bleuIcone),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CarteStylisee(
                    child: Column(
                      children: [
                        _ChampSeuil(
                          controleur: _controleurs['acidite']!,
                          libelle: l10n.seuilAciditeConformiteLabel,
                          modifiable: estAdmin,
                        ),
                        const Divider(height: 24, color: AppColors.grisLigne),
                        _ChampSeuil(
                          controleur: _controleurs['peroxyde']!,
                          libelle: l10n.seuilPeroxydeConformiteLabel,
                          modifiable: estAdmin,
                        ),
                        const Divider(height: 24, color: AppColors.grisLigne),
                        _ChampSeuil(
                          controleur: _controleurs['evoo']!,
                          libelle: l10n.seuilEvooLabel,
                          modifiable: estAdmin,
                        ),
                        const Divider(height: 24, color: AppColors.grisLigne),
                        _ChampSeuil(
                          controleur: _controleurs['voo']!,
                          libelle: l10n.seuilVooLabel,
                          modifiable: estAdmin,
                        ),
                      ],
                    ),
                  ),
                  if (estAdmin) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vertOlive,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: state.enregistrementEnCours
                            ? null
                            : () => _enregistrer(state.configuration!),
                        child: state.enregistrementEnCours
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                              )
                            : Text(l10n.enregistrerBouton, style: AppTextStyles.boutonPrincipal),
                      ),
                    ),
                  ],
                ],
              );
            }),
    );
  }
}

class _ChampSeuil extends StatelessWidget {
  final TextEditingController controleur;
  final String libelle;
  final bool modifiable;

  const _ChampSeuil({required this.controleur, required this.libelle, required this.modifiable});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controleur,
      enabled: modifiable,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: libelle, suffixText: '%'),
    );
  }
}
