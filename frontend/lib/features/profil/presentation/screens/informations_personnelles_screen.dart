import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/profil_entity.dart';
import '../../domain/usecases/modifier_profil_usecase.dart';
import '../providers/profil_provider.dart';

/// Sous-écran "Informations personnelles" — s'ouvre DANS l'onglet
/// Paramètres (voir core/navigation/app_router.dart), la barre du bas
/// reste visible. Enregistre via PATCH /api/utilisateurs/moi/.
class InformationsPersonnellesScreen extends ConsumerStatefulWidget {
  const InformationsPersonnellesScreen({super.key});

  @override
  ConsumerState<InformationsPersonnellesScreen> createState() =>
      _InformationsPersonnellesScreenState();
}

class _InformationsPersonnellesScreenState
    extends ConsumerState<InformationsPersonnellesScreen> {
  late final TextEditingController _nomControleur;
  late final TextEditingController _telephoneControleur;
  late final TextEditingController _fonctionControleur;
  late final TextEditingController _laboratoireControleur;
  late final TextEditingController _institutionControleur;
  bool _initialise = false;

  void _initialiser(ProfilEntity profil) {
    if (_initialise) return;
    _initialise = true;
    _nomControleur = TextEditingController(text: profil.nom);
    _telephoneControleur = TextEditingController(text: profil.telephone);
    _fonctionControleur = TextEditingController(text: profil.fonction);
    _laboratoireControleur = TextEditingController(text: profil.laboratoire);
    _institutionControleur = TextEditingController(text: profil.institution);
  }

  @override
  void dispose() {
    if (_initialise) {
      _nomControleur.dispose();
      _telephoneControleur.dispose();
      _fonctionControleur.dispose();
      _laboratoireControleur.dispose();
      _institutionControleur.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = context.l10n;
    final resultat = await ref.read(profilProvider.notifier).modifierProfil(
          ModifierProfilParams(
            nom: _nomControleur.text.trim(),
            telephone: _telephoneControleur.text.trim(),
            fonction: _fonctionControleur.text.trim(),
            laboratoire: _laboratoireControleur.text.trim(),
            institution: _institutionControleur.text.trim(),
          ),
        );
    if (!mounted) return;
    resultat.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.messageLocalise(context)))),
      (_) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profilMisAJourMessage))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.informationsPersonnellesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: state.profil == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.vertOlive))
          : Builder(builder: (context) {
              _initialiser(state.profil!);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _nomControleur,
                    decoration: InputDecoration(labelText: l10n.champNom),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telephoneControleur,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.champTelephone),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fonctionControleur,
                    decoration: InputDecoration(labelText: l10n.champFonction),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _laboratoireControleur,
                    decoration: InputDecoration(labelText: l10n.champLaboratoire),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _institutionControleur,
                    decoration: InputDecoration(labelText: l10n.champInstitution),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vertOlive,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: state.enregistrementEnCours ? null : _enregistrer,
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
              );
            }),
    );
  }
}
