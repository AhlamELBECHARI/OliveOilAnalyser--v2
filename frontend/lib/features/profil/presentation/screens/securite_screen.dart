import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/changer_mot_de_passe_provider.dart';

/// Sous-écran "Sécurité" — changement de mot de passe via POST
/// /api/auth/changer-mot-de-passe/ (vérifie l'ancien, blackliste les
/// sessions existantes côté backend).
class SecuriteScreen extends ConsumerStatefulWidget {
  const SecuriteScreen({super.key});

  @override
  ConsumerState<SecuriteScreen> createState() => _SecuriteScreenState();
}

class _SecuriteScreenState extends ConsumerState<SecuriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancienControleur = TextEditingController();
  final _nouveauControleur = TextEditingController();
  final _confirmationControleur = TextEditingController();

  @override
  void dispose() {
    _ancienControleur.dispose();
    _nouveauControleur.dispose();
    _confirmationControleur.dispose();
    super.dispose();
  }

  String? _validerAncien(String? valeur) {
    if (valeur == null || valeur.isEmpty) return context.l10n.erreurMotDePasseRequis;
    return null;
  }

  String? _validerNouveau(String? valeur) {
    if (valeur == null || valeur.isEmpty) return context.l10n.erreurMotDePasseRequis;
    if (valeur.length < 8) return context.l10n.erreurMinimum8Caracteres;
    return null;
  }

  String? _validerConfirmation(String? valeur) {
    if (valeur == null || valeur.isEmpty) return context.l10n.erreurConfirmationRequise;
    if (valeur != _nouveauControleur.text) return context.l10n.erreurMotsDePasseNeCorrespondentPas;
    return null;
  }

  void _soumettre() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(changerMotDePasseProvider.notifier).changer(
            ancien: _ancienControleur.text,
            nouveau: _nouveauControleur.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(changerMotDePasseProvider, (previous, next) {
      if (next.succes && previous?.succes != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.motDePasseModifieMessage)),
        );
        _ancienControleur.clear();
        _nouveauControleur.clear();
        _confirmationControleur.clear();
      }
    });

    final state = ref.watch(changerMotDePasseProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.securiteTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _ancienControleur,
              obscureText: true,
              validator: _validerAncien,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: l10n.ancienMotDePasseLabel),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nouveauControleur,
              obscureText: true,
              validator: _validerNouveau,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: l10n.nouveauMotDePasse),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmationControleur,
              obscureText: true,
              validator: _validerConfirmation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: l10n.champConfirmerMotDePasse),
            ),
            if (state.echec != null) ...[
              const SizedBox(height: 12),
              Text(
                state.echec!.messageLocalise(context),
                style: AppTextStyles.erreurChamp.copyWith(fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vertOlive,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: state.enChargement ? null : _soumettre,
                child: state.enChargement
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                      )
                    : Text(l10n.changerMotDePasseBouton, style: AppTextStyles.boutonPrincipal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
