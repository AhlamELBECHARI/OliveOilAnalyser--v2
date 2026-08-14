import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/creation_utilisateur_provider.dart';

Future<void> afficherFeuilleCreerUtilisateur(
  BuildContext context, {
  required VoidCallback onCree,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.fond,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _FeuilleCreerUtilisateur(onCree: onCree),
  );
}

class _FeuilleCreerUtilisateur extends ConsumerStatefulWidget {
  final VoidCallback onCree;

  const _FeuilleCreerUtilisateur({required this.onCree});

  @override
  ConsumerState<_FeuilleCreerUtilisateur> createState() => _FeuilleCreerUtilisateurState();
}

class _FeuilleCreerUtilisateurState extends ConsumerState<_FeuilleCreerUtilisateur> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'utilisateur';

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(creationUtilisateurProvider.notifier).soumettre(
            nom: _nomController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(creationUtilisateurProvider, (previous, next) {
      if (next.reussie && previous?.reussie != true) {
        widget.onCree();
        Navigator.of(context).pop();
      }
    });

    final state = ref.watch(creationUtilisateurProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.creerCompteTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: l10n.champNomUtilisateur),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.champEmail),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.champMotDePasse),
              validator: (v) =>
                  (v == null || v.length < 8) ? l10n.champObligatoire : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: InputDecoration(labelText: l10n.champRoleLabel),
              items: [
                DropdownMenuItem(value: 'utilisateur', child: Text(l10n.roleUtilisateurLabel)),
                DropdownMenuItem(
                  value: 'administrateur',
                  child: Text(l10n.roleAdministrateurLabel),
                ),
              ],
              onChanged: (valeur) => setState(() => _role = valeur ?? 'utilisateur'),
            ),
            if (state.echec != null) ...[
              const SizedBox(height: 8),
              Text(
                state.echec!.messageLocalise(context),
                style: AppTextStyles.erreurChamp.copyWith(fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertOlive,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: state.enCours ? null : _soumettre,
              child: state.enCours
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : Text(l10n.creerBouton, style: AppTextStyles.boutonPrincipal),
            ),
          ],
        ),
      ),
    );
  }
}
