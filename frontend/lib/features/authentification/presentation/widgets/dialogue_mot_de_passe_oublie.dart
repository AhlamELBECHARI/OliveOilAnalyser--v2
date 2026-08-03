import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/reset_password_provider.dart';

/// Boîte de dialogue déclenchée par "Mot de passe oublié ?" : demande un
/// email puis appelle POST /api/auth/reset-password/. Le backend ne révèle
/// jamais si l'email existe, donc un même message de confirmation générique
/// s'affiche dans tous les cas de succès.
class DialogueMotDePasseOublie extends ConsumerStatefulWidget {
  const DialogueMotDePasseOublie({super.key});

  @override
  ConsumerState<DialogueMotDePasseOublie> createState() =>
      _DialogueMotDePasseOublieState();
}

class _DialogueMotDePasseOublieState
    extends ConsumerState<DialogueMotDePasseOublie> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordProvider);

    ref.listen(resetPasswordProvider, (previous, next) {
      if (next.demandeEnvoyee && previous?.demandeEnvoyee != true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Si un compte existe pour cet email, un lien de réinitialisation vient d'être envoyé.",
            ),
          ),
        );
      }
    });

    return AlertDialog(
      backgroundColor: AppColors.fond,
      title: const Text('Mot de passe oublié', style: AppTextStyles.bienvenue),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisissez votre email pour recevoir un lien de réinitialisation.',
              style: AppTextStyles.sousTexteBienvenue,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Email requis';
                }
                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!regex.hasMatch(valeur.trim())) {
                  return 'Format email invalide';
                }
                return null;
              },
            ),
            if (state.messageErreur != null) ...[
              const SizedBox(height: 8),
              Text(state.messageErreur!, style: AppTextStyles.erreurChamp),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler', style: AppTextStyles.sousTexteBienvenue),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.vertOlive),
          onPressed: state.enChargement
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ref.read(resetPasswordProvider.notifier).demander(
                          email: _emailController.text.trim(),
                        );
                  }
                },
          child: state.enChargement
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blanc,
                  ),
                )
              : const Text('Envoyer'),
        ),
      ],
    );
  }
}
